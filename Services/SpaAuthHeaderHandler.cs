using System.Diagnostics;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

/// <summary>
/// Attaches X-Customer-Id and X-User-Role headers from the Blazor-scoped
/// UserSessionService to every outgoing SPA/PayOS request. Backend controllers
/// (SpaBookingController, etc.) resolve the customer from this header instead
/// of trusting query params.
/// </summary>
public sealed class SpaAuthHeaderHandler : DelegatingHandler
{
    private readonly IServiceProvider _services;

    // Static counters across all handler instances — cheap and process-global.
    private static long _invocationCount;
    private static long _totalMs;
    private static long _attachedHeaders;
    private static long _missingSession;
    private static long _exceptionCount;

    public SpaAuthHeaderHandler(IServiceProvider services)
    {
        _services = services;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var invocationId = Interlocked.Increment(ref _invocationCount);
        var sw = Stopwatch.StartNew();
        try
        {
            // CRITICAL: We must NEVER call UserSession.LoadAsync() from the handler.
            // Doing so issues a JS interop roundtrip and ProtectedLocalStorage call
            // on every outbound HTTP request, which is what produced the original
            // observed latency. Read the already-resolved in-memory user only.
            //
            // ResolveScopedAvoidHttpClient is needed because HttpClient factory
            // creates the handler outside the interactive Blazor scope, so
            // _services.GetService<UserSessionService>() would return null.
            // The user's CurrentUser is set by TopBar/Header/etc. and survives
            // across HTTP calls within the same circuit.
            AuthResponseDto? user = null;
            try
            {
                user = (_services.GetService(typeof(UserSessionService)) as UserSessionService)?.CurrentUser;
            }
            catch (Exception ex)
            {
                Interlocked.Increment(ref _exceptionCount);
                Debug.WriteLine($"[SpaAuthHeaderHandler#{invocationId}] UserSession lookup threw: {ex.GetType().Name} {ex.Message}");
            }

            if (user is not null)
            {
                if (!request.Headers.Contains("X-Customer-Id") && user.UserId > 0)
                {
                    if (request.Headers.TryAddWithoutValidation("X-Customer-Id", user.UserId.ToString()))
                    {
                        Interlocked.Increment(ref _attachedHeaders);
                    }
                }

                if (!request.Headers.Contains("X-User-Id") && user.UserId > 0)
                {
                    request.Headers.TryAddWithoutValidation("X-User-Id", user.UserId.ToString());
                }

                if (!request.Headers.Contains("X-User-Role") && !string.IsNullOrWhiteSpace(user.Role))
                {
                    request.Headers.TryAddWithoutValidation("X-User-Role", user.Role);
                }
            }
            else
            {
                Interlocked.Increment(ref _missingSession);
            }

            return await base.SendAsync(request, cancellationToken);
        }
        finally
        {
            sw.Stop();
            Interlocked.Add(ref _totalMs, sw.ElapsedMilliseconds);
            if ((invocationId % 50) == 0)
            {
                var avg = invocationId > 0
                    ? Interlocked.Read(ref _totalMs) / invocationId
                    : 0;
                Debug.WriteLine(
                    $"[SpaAuthHeaderHandler] sent={invocationId} attached={Interlocked.Read(ref _attachedHeaders)} noSession={Interlocked.Read(ref _missingSession)} ex={Interlocked.Read(ref _exceptionCount)} avgMs={avg}");
            }
        }
    }
}
