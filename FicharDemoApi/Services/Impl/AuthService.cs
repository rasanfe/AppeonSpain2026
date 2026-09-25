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

using FicharApi.Models;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace FicharApi.Services.Impl
{
    public class AuthService : IAuthService
    {
        private readonly DefaultDataContext _dataContext;
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpAccessor;
        public AuthService(DefaultDataContext dataContext, IConfiguration configuration, IHttpContextAccessor httpAccessor)
        {
            _dataContext = dataContext;
            _configuration = configuration;
            _httpAccessor = httpAccessor;
        }
        
        public Usuarios Login(AuthUser AuthRequest)
        {
            Usuarios usuario = _dataContext.SqlModelMapper.Load<Usuarios>(AuthRequest.Username, AuthRequest.Password).FirstOrDefault();
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
