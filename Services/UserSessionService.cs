using System.Diagnostics;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.JSInterop;
using PetShop.Models;

namespace PetShop.Services;

public sealed class UserSessionService
{
    private const string AuthKey = "authUser";
    private readonly ProtectedLocalStorage _storage;

    public UserSessionService(ProtectedLocalStorage storage)
    {
        _storage = storage;
    }

    public event Action? Changed;

    public AuthResponseDto? CurrentUser { get; private set; }

    public bool IsAuthenticated => CurrentUser is not null;

    private Task? _loadTask;
    private static long _loadInvocationCount;
    private static long _loadTotalMs;

    public async Task<AuthResponseDto?> LoadAsync()
    {
        Interlocked.Increment(ref _loadInvocationCount);
        var sw = Stopwatch.StartNew();
        try
        {
            // Share the in-flight load across concurrent callers.
            // The first caller populates _loadTask; everyone else awaits the same task.
            // If LoadCoreAsync detected pre-render failure, it resets _loadTask to null
            // so subsequent calls retry once the circuit becomes interactive.
            if (_loadTask is null)
            {
                _loadTask = LoadCoreAsync();
            }
            await _loadTask;
            return CurrentUser;
        }
        finally
        {
            sw.Stop();
            Interlocked.Add(ref _loadTotalMs, sw.ElapsedMilliseconds);
            if (Interlocked.CompareExchange(ref _verboseLogCounter, 1, 0) == 0)
            {
                var invocationCount = Interlocked.Read(ref _loadInvocationCount);
                var totalMs = Interlocked.Read(ref _loadTotalMs);
                var avgMs = invocationCount > 0 ? totalMs / invocationCount : 0;
                Debug.WriteLine($"[UserSession] LoadAsync complete. totalInvocations={invocationCount} totalMs={totalMs} avgMs={avgMs} CurrentUser={(CurrentUser is null ? "null" : $"id={CurrentUser.UserId}")}");
            }
        }
    }

    // Emit a one-shot summary line per process so verbose calls do not flood the output.
    private static int _verboseLogCounter;

    private async Task LoadCoreAsync()
    {
        try
        {
            var result = await _storage.GetAsync<AuthResponseDto>(AuthKey);
            CurrentUser = result.Success ? result.Value : null;
            NotifyChangedSafe();
        }
        catch (InvalidOperationException)
        {
            // Protected browser storage is only available after the interactive circuit starts.
            // Clear the cached task so the next LoadAsync call retries instead of awaiting a doomed task.
            CurrentUser = null;
            _loadTask = null;
        }
        catch (JSDisconnectedException)
        {
            // Circuit disconnected; session will be reloaded on reconnect.
            CurrentUser = null;
            _loadTask = null;
        }
    }

    public async Task SignInAsync(AuthResponseDto user)
    {
        CurrentUser = user ?? throw new ArgumentNullException(nameof(user));
        // The storage roundtrip is awaited but never silently swallowed.
        try
        {
            await _storage.SetAsync(AuthKey, user);
        }
        catch (Exception ex) when (ex is JSDisconnectedException or InvalidOperationException)
        {
            // Storage unavailable (reconnect / pre-render). The in-memory session is already updated.
            Debug.WriteLine($"[UserSession] SignInAsync storage write skipped: {ex.GetType().Name}");
        }
        NotifyChangedSafe();
    }

    public async Task SignOutAsync()
    {
        CurrentUser = null;
        try
        {
            await _storage.DeleteAsync(AuthKey);
        }
        catch (Exception ex) when (ex is JSDisconnectedException or InvalidOperationException)
        {
            Debug.WriteLine($"[UserSession] SignOutAsync storage delete skipped: {ex.GetType().Name}");
        }
        NotifyChangedSafe();
    }

    private void NotifyChangedSafe()
    {
        try
        {
            Changed?.Invoke();
        }
        catch (Exception ex)
        {
            // A subscriber may be unsubscribed or in a bad state — never let the storage op failure
            // propagate because of event fan-out.
            Debug.WriteLine($"[UserSession] Changed handler threw: {ex.GetType().Name}");
        }
    }
}
