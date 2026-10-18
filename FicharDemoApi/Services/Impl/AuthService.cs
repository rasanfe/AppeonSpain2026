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
//10-09-2026: AuthService.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using FicharApi.Config;
using FicharApi.Data;
using FicharApi.Models;

namespace FicharApi.Services.Impl
{
    public class AuthService : IAuthService
    {
        private readonly JsonDatabase _db;

        public AuthService(JsonDatabase db)
        {
            _db = db;
        }

        public async Task<Usuarios> LoginAsync(AuthUser AuthRequest, CancellationToken cancellationToken)
        {
            var usuarios = await _db.LeerAsync<Usuarios>(DemoConstants.TablaUsuarios, cancellationToken);

            Usuarios? usuario = usuarios.FirstOrDefault(u =>
                Texto.Igual(u.Usuario, AuthRequest.Username) && Texto.Igual(u.Pin, AuthRequest.Password));
            if (usuario != null)
            {
                usuario.IsValid = true;
                
            }
            else
            {
                usuario = new Usuarios() { IsValid = false };
            }

            return usuario;
            
        }
        
        
        
    }
}
