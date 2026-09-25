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
//10-09-2026: UsuariosController.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System;
using System.Linq;
using System.Collections.Generic;
using FicharApi.Services;
using System.Threading.Tasks;
using System.Threading;

namespace FicharApi.Controllers
{
    [Route("api/[controller]/[action]")]
	[ApiController]
	[Authorize]
	public class UsuariosController : ControllerBase
    {
        private readonly IUsuariosService _iusuariosservice;

        public UsuariosController(IUsuariosService iusuariosservice)
        {
            _iusuariosservice = iusuariosservice;
        }

        //GET api/Usuarios/EmpresaUsuario/{usuario}
        [HttpGet("{usuario}")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<string>> EmpresaUsuarioAsync(string usuario)
        {
            try
            {
                string empresaUsuario = await _iusuariosservice.EmpresaUsuarioAsync(usuario, default);
                return Ok(new { empresaUsuario });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        //GET api/Usuarios/GrupoUsuario/{usuario}
        [HttpGet("{usuario}")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<string>> GrupoUsuarioAsync(string usuario)
        {
            try
            {
                string grupoUsuario = await _iusuariosservice.GrupoUsuarioAsync(usuario, default);
                return Ok(new { grupoUsuario });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        //GET api/Usuarios/EmpleadoUsuario/{usuario}
        [HttpGet("{usuario}")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<string>> EmpleadoUsuarioAsync(string usuario)
        {
            try
            {
                string empleadoUsuario = await _iusuariosservice.EmpleadoUsuarioAsync(usuario, default);
                return Ok(new { empleadoUsuario });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        //GET api/Usuarios/UsuarioEmpleado/{usuario}/{empleado}
        [HttpGet("{empresa}/{empleado}")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<string>> UsuarioEmpleadoAsync(string empresa, string empleado)
        {
            try
            {
                string usuarioEmpleado = await _iusuariosservice.UsuarioEmpleadoAsync(empresa, empleado, default);
                return Ok(new { usuarioEmpleado });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }
        

    }
}