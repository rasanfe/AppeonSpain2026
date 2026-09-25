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
//10-09-2026: TokenService.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using FicharApi.Config;
using FicharApi.Models;
using Microsoft.IdentityModel.Tokens;

namespace FicharApi.Services.Impl
{
    /// <summary>
    /// JWT de manual, sin florituras: es una demo. La clave sale del .env.
    /// </summary>
    public class TokenService : ITokenService
    {
        private readonly DemoSettings _ajustes;

        public TokenService(DemoSettings ajustes)
        {
            _ajustes = ajustes;
        }

        public AuthResponse CrearToken(Usuarios usuario, string? origen)
        {
            var expira = DateTime.UtcNow.AddHours(DemoConstants.TokenHoras);

            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, usuario.Usuario ?? string.Empty),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new(DemoConstants.ClaimEmpresa,  usuario.Empresa  ?? string.Empty),
                new(DemoConstants.ClaimEmpleado, usuario.Empleado ?? string.Empty),
                new(DemoConstants.ClaimGrupo,    usuario.Grupo    ?? string.Empty),
                new(DemoConstants.ClaimOrigen,   origen           ?? "WEB")
            };

            var credenciales = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_ajustes.JwtKey)),
                SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: DemoConstants.JwtIssuer,
                audience: DemoConstants.JwtAudience,
                claims: claims,
                expires: expira,
                signingCredentials: credenciales);

            return new AuthResponse
            {
                Token = new JwtSecurityTokenHandler().WriteToken(token),
                Expira = expira,
                Usuario = usuario.Usuario,
                Empresa = usuario.Empresa,
                Empleado = usuario.Empleado,
                Grupo = usuario.Grupo,
                Origen = origen ?? "WEB"
            };
        }
    }
}
