using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsDevelopment())
{
    builder.Configuration.AddUserSecrets<Program>(optional: true, reloadOnChange: true);
}

builder.Services.AddControllersWithViews()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents(options => options.DetailedErrors = true);

builder.Services.AddHttpContextAccessor();
builder.Services.AddHttpClient<PetShop.Interfaces.IProductCatalogClient, PetShop.Services.ProductCatalogClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    var baseUri = context is null
        ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/"
        : $"{context.Request.Scheme}://{context.Request.Host}/";

    client.BaseAddress = new Uri(baseUri, UriKind.Absolute);
});
builder.Services.AddHttpClient<PetShop.Interfaces.IAuthClient, PetShop.Services.AuthClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
});
builder.Services.AddHttpClient<PetShop.Interfaces.ICheckoutClient, PetShop.Services.CheckoutClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
});
builder.Services.AddHttpClient<PetShop.Interfaces.IOrderClient, PetShop.Services.OrderClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
});
builder.Services.AddHttpClient<PetShop.Interfaces.IReviewClient, PetShop.Services.ReviewClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
});
builder.Services.AddHttpClient<PetShop.Interfaces.IPaymentClient, PetShop.Services.PaymentClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
});
builder.Services.AddTransient<PetShop.Services.SpaAuthHeaderHandler>();
builder.Services.AddHttpClient<PetShop.Interfaces.IPetServiceClient, PetShop.Services.PetServiceClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
});
builder.Services.AddHttpClient<PetShop.Interfaces.ISpaBookingClient, PetShop.Services.SpaBookingClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
})
    .AddHttpMessageHandler<PetShop.Services.SpaAuthHeaderHandler>();
builder.Services.AddHttpClient<PetShop.Interfaces.IPetsClient, PetShop.Services.PetsClient>((sp, client) =>
{
    var context = sp.GetRequiredService<IHttpContextAccessor>().HttpContext;
    client.BaseAddress = new Uri(context is null ? builder.Configuration["App:BaseUrl"] ?? "http://localhost:5286/" : $"{context.Request.Scheme}://{context.Request.Host}/");
})
    .AddHttpMessageHandler<PetShop.Services.SpaAuthHeaderHandler>();
builder.Services.AddScoped<PetShop.Services.UserSessionService>();
builder.Services.AddScoped<PetShop.Services.CartStateService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "PetShop API", Version = "v1" });
    options.OperationFilter<FormFileOperationFilter>();
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendDev", policy =>
    {
        policy
            .WithOrigins("http://localhost:5173")
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var dbConnectionString = builder.Configuration.GetConnectionString("DBDefault")
    ?? builder.Configuration.GetConnectionString("DefaultConnection");
if (string.IsNullOrWhiteSpace(dbConnectionString))
{
    throw new InvalidOperationException(
        "Missing connection string 'ConnectionStrings:DBDefault' or 'ConnectionStrings:DefaultConnection'. " +
        "Add it to appsettings.json/appsettings.Development.json, or set environment variable 'ConnectionStrings__DBDefault'.");
}

builder.Services.AddDbContext<PetShop.Data.ShopPetDatabaseContext>(options =>
    options.UseSqlServer(dbConnectionString));

builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.IdleTimeout = TimeSpan.FromHours(8);
});

builder.Services.AddScoped<PetShop.Interfaces.IProductRepository_temp, PetShop.Repositories.ProductRepository_temp>();
builder.Services.AddScoped<PetShop.Interfaces.IProductService_temp, PetShop.Services.ProductService_temp>();
builder.Services.AddScoped<PetShop.Interfaces.IAuthRepository, PetShop.Repositories.AuthRepository>();
builder.Services.AddScoped<PetShop.Interfaces.IAuthService, PetShop.Services.AuthService>();
builder.Services.AddScoped<PetShop.Interfaces.IEmailService, PetShop.Services.EmailService>();
builder.Services.AddScoped<PetShop.Interfaces.IPetServiceRepository, PetShop.Repositories.PetServiceRepository>();
builder.Services.AddScoped<PetShop.Interfaces.IPetServiceService, PetShop.Services.PetServiceService>();
builder.Services.AddScoped<PetShop.Interfaces.ISpaBookingRepository, PetShop.Repositories.SpaBookingRepository>();
builder.Services.AddScoped<PetShop.Interfaces.ISpaBookingService, PetShop.Services.SpaBookingService>();
builder.Services.AddScoped<PetShop.Interfaces.IReviewRepository, PetShop.Repositories.ReviewRepository>();
builder.Services.AddScoped<PetShop.Interfaces.IAttendanceService, PetShop.Services.AttendanceService>();
builder.Services.AddScoped<PetShop.Interfaces.IPayrollService, PetShop.Services.PayrollService>();
builder.Services.AddScoped<PetShop.Interfaces.IBoardingRepository, PetShop.Repositories.BoardingRepository>();
builder.Services.AddScoped<PetShop.Interfaces.IBoardingService, PetShop.Services.BoardingService>();

builder.Services.Configure<PetShop.Models.PayOSOptions>(
    builder.Configuration.GetSection(PetShop.Models.PayOSOptions.SectionName));
builder.Services.AddHttpClient<PetShop.Interfaces.IPayOSService, PetShop.Services.PayOSService>()
    .ConfigureHttpClient((sp, client) =>
    {
        var payosOptions = sp.GetRequiredService<Microsoft.Extensions.Options.IOptions<PetShop.Models.PayOSOptions>>().Value;
        client.DefaultRequestHeaders.Add("x-client-id", payosOptions.ClientId);
        client.DefaultRequestHeaders.Add("x-api-key", payosOptions.ApiKey);
        client.Timeout = TimeSpan.FromSeconds(30);
    });

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseCors("FrontendDev");
app.UseSession();
app.UseAuthorization();
app.UseAntiforgery();

app.Use(async (context, next) =>
{
    var forwardedFor = context.Request.Headers["X-Forwarded-For"].FirstOrDefault();
    if (!string.IsNullOrWhiteSpace(forwardedFor))
    {
        context.Items["RealClientIp"] = forwardedFor.Split(',')[0].Trim();
    }

    await next();
});

app.MapControllers();

app.MapRazorComponents<PetShop_PRN222.Components.App>()
    .AddInteractiveServerRenderMode();

app.MapControllerRoute(
    name: "default",
    pattern: "mvc/{controller=ProductsPage}/{action=Index}/{id?}");

app.Run();

public sealed class FormFileOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        var formFileParams = context.ApiDescription.ActionDescriptor.Parameters
            .OfType<Microsoft.AspNetCore.Mvc.Abstractions.ParameterDescriptor>()
            .Where(p => p.ParameterType == typeof(IFormFile))
            .ToList();

        if (formFileParams.Count == 0)
        {
            foreach (var param in operation.Parameters)
            {
                if (param.Schema is not null && param.Schema.Format == "binary")
                {
                    param.Schema.Type = "string";
                    param.Schema.Format = "binary";
                }
            }

            return;
        }

        operation.RequestBody = new OpenApiRequestBody
        {
            Content = new Dictionary<string, OpenApiMediaType>
            {
                ["multipart/form-data"] = new OpenApiMediaType
                {
                    Schema = new OpenApiSchema
                    {
                        Type = "object",
                        Properties = formFileParams.ToDictionary(
                            p => p.Name ?? "file",
                            _ => new OpenApiSchema { Type = "string", Format = "binary" }),
                        Required = new HashSet<string>(formFileParams.Select(p => p.Name ?? "file"))
                    }
                }
            }
        };

        operation.Parameters.Clear();
    }
}
