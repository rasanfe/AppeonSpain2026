//╔═════════════════════════════════════════════════════════════════════════════════╗
//║                                                                                 ║
//║  ██████╗ ███████╗██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗  ║
//║  ██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║  ║
//║  ██████╔╝███████╗██████╔╝███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║  ║
//║  ██╔══██╗╚════██║██╔══██╗╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║  ║
//║  ██║  ██║███████║██║  ██║███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║  ║
//║  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝  ║
//║                                                                                 ║
//╚═════════════════════════════════════════════════════════════════════════════════╝
//
//10-09-2026: Program.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System.Text;
using System.IO.Compression;
using DWNet.Data.AspNetCore;
using FicharApi;
using FicharApi.Config;
using FicharApi.Services;
using FicharApi.Services.Impl;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using SnapObjects.Data;
using SnapObjects.Data.AspNetCore;
using SnapObjects.Data.SqlServer;

var builder = WebApplication.CreateBuilder(args);

// --- Configuracion: el .env manda -------------------------------------------
EnvFile.Cargar(builder.Configuration, AppContext.BaseDirectory);
var ajustes = new DemoSettings(builder.Configuration);
builder.Services.AddSingleton(ajustes);
builder.WebHost.UseUrls($"http://0.0.0.0:{ajustes.Puerto}");

// --- MVC + DataWindow de Appeon ---------------------------------------------
builder.Services.AddControllers(m =>
{
    m.UseCoreIntegrated();
    m.UsePowerBuilderIntegrated();
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddGzipCompression(CompressionLevel.Fastest);
builder.Services.AddHttpContextAccessor();

builder.Services.AddDataContext<DefaultDataContext>(
    m => m.UseSqlServer(ajustes.ConnectionString));

// --- Seguridad: esto es lo que en 2024 NO estaba ----------------------------
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opciones =>
    {
        opciones.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = DemoConstants.JwtIssuer,
            ValidAudience = DemoConstants.JwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(ajustes.JwtKey)),
            ClockSkew = TimeSpan.Zero
        };
    });
builder.Services.AddAuthorization();

// --- Swagger con boton Authorize --------------------------------------------
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Fichar Demo API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Pegar aqui el token que devuelve /api/Auth/Login"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// --- CORS: solo para desarrollo, cuando la web corre en Vite ----------------
const string CorsDesarrollo = "desarrollo";
builder.Services.AddCors(o => o.AddPolicy(CorsDesarrollo, p => p
    .SetIsOriginAllowed(origen => new Uri(origen).IsLoopback)
    .AllowAnyHeader()
    .AllowAnyMethod()));

// --- Servicios de negocio (los de 2024, tal cual) ---------------------------
builder.Services.AddSingleton<ITicketService, TicketService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<INomregistroService, NomregistroService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUsuariosService, UsuariosService>();
builder.Services.AddScoped<IEmpleadosService, EmpleadosService>();
builder.Services.AddScoped<ISistemaService, SistemaService>();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.UseCors(CorsDesarrollo);

// --- La API sirve TAMBIEN la web: un solo proceso para toda la demo ---------
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.UseDataWindow();

// Rutas del router de React que no son de la API -> index.html
app.MapFallbackToFile("index.html");

app.Run();
