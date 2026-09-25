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
//10-09-2026: AuthController.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System.Security.Claims;
using FicharApi.Config;
using FicharApi.Models;
using FicharApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FicharApi.Controllers
{
    /// <summary>
    /// El MISMO login para los tres clientes: PowerBuilder, navegador y movil.
    /// En 2024 esta API se enseño sin seguridad; aqui esta cerrada con JWT.
    /// </summary>
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _auth;
        private readonly ITokenService _tokens;
        private readonly ITicketService _tickets;

        public AuthController(IAuthService auth, ITokenService tokens, ITicketService tickets)
        {
            _auth = auth;
            _tokens = tokens;
            _tickets = tickets;
        }

        /// <summary>POST api/Auth/Login — usuario + PIN, devuelve el JWT.</summary>
        [HttpPost]
        [AllowAnonymous]
        [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public ActionResult<AuthResponse> Login([FromBody] AuthUser peticion)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var usuario = _auth.Login(peticion);
            if (usuario is null || !usuario.IsValid) return Unauthorized();

            return Ok(_tokens.CrearToken(usuario, peticion.Origen));
        }

        /// <summary>
        /// POST api/Auth/Ticket — lo llama PowerBuilder con SU token.
        /// Devuelve un ticket de un solo uso para dárselo a la web embebida.
        /// </summary>
        [HttpPost]
        [ProducesResponseType(typeof(TicketResponse), StatusCodes.Status200OK)]
        public ActionResult<TicketResponse> Ticket()
        {
            var usuario = UsuarioDelToken();
            var ticket = _tickets.Crear(usuario, DemoConstants.TicketSegundos);

            return Ok(new TicketResponse
            {
                Ticket = ticket,
                ExpiraSegundos = DemoConstants.TicketSegundos
            });
        }

        /// <summary>
        /// POST api/Auth/Redeem — lo llama la web al abrirse dentro de PowerBuilder.
        /// Canjea el ticket por su propio JWT: el usuario no vuelve a loguearse.
        /// </summary>
        [HttpPost]
        [AllowAnonymous]
        [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public ActionResult<AuthResponse> Redeem([FromBody] RedeemRequest peticion)
        {
            if (string.IsNullOrWhiteSpace(peticion.Ticket)) return BadRequest();

            var usuario = _tickets.Canjear(peticion.Ticket);
            if (usuario is null) return Unauthorized();

            // El token que nace del ticket sabe que viene de PowerBuilder.
            return Ok(_tokens.CrearToken(usuario, "PB"));
        }

        /// <summary>GET api/Auth/Me — quien soy, segun el token.</summary>
        [HttpGet]
        [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
        public ActionResult<AuthResponse> Me()
        {
            var usuario = UsuarioDelToken();
            return Ok(new AuthResponse
            {
                Usuario = usuario.Usuario,
                Empresa = usuario.Empresa,
                Empleado = usuario.Empleado,
                Grupo = usuario.Grupo,
                Origen = Claim(DemoConstants.ClaimOrigen)
            });
        }

        private Usuarios UsuarioDelToken() => new()
        {
            Usuario = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? Claim("sub"),
            Empresa = Claim(DemoConstants.ClaimEmpresa),
            Empleado = Claim(DemoConstants.ClaimEmpleado),
            Grupo = Claim(DemoConstants.ClaimGrupo),
            IsValid = true
        };

        private string? Claim(string tipo) => User.FindFirst(tipo)?.Value;
    }
}
