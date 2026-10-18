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
//10-09-2026: NomregistroController.cs
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
using FicharApi.Config;
using FicharApi.Data;
using FicharApi.Models;

namespace FicharApi.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class NomregistroController : ControllerBase
    {
        private readonly INomregistroService _nomregistroService;
        
        public NomregistroController(INomregistroService inomregistroService)
        {
            _nomregistroService = inomregistroService;
        }
        
        
        //GET api/Nomregistro/Retrieve/{as_empresa}/{as_empelado}/{adt_fecha}
        /// <summary>Solo los fichajes PROPIOS: empresa y empleado tienen que ser los del token, o 403.</summary>
        [HttpGet("{as_empresa}/{as_empelado}/{as_fecha}")]
        [ProducesResponseType(typeof(IEnumerable<Fichaje>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<IEnumerable<Fichaje>>> RetrieveAsync(string as_empresa, string as_empelado, string as_fecha)
        {
            if (!EmpleadoDelToken(out var empresa, out var empleado)
                || !Texto.Igual(as_empresa, empresa)
                || !Texto.Igual(as_empelado, empleado))
            {
                return Forbid();
            }

            DateTime? fecha;
            
            if (as_fecha == null)
            {
                fecha = null;
            }
            else
            {
                fecha = DateTime.Parse(as_fecha);
            }
            
            try
            {
                var result = await _nomregistroService.RetrieveAsync(as_empresa, as_empelado, fecha, default);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        //GET api/Nomregistro/RetrieveHistorico/{empresa}/{empleado}/{desde}/{hasta}
        /// <summary>
        /// Los fichajes de un rango de días, para el historial del mes (la misma ruta
        /// que WebFichar). Solo los PROPIOS, como Retrieve: si no, 403.
        /// </summary>
        [HttpGet("{as_empresa}/{as_empleado}/{as_desde}/{as_hasta}")]
        [ProducesResponseType(typeof(IEnumerable<Fichaje>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<IEnumerable<Fichaje>>> RetrieveHistoricoAsync(
            string as_empresa, string as_empleado, string as_desde, string as_hasta)
        {
            if (!EmpleadoDelToken(out var empresa, out var empleado)
                || !Texto.Igual(as_empresa, empresa)
                || !Texto.Igual(as_empleado, empleado))
            {
                return Forbid();
            }

            if (!DateTime.TryParse(as_desde, out var desde) || !DateTime.TryParse(as_hasta, out var hasta))
            {
                return BadRequest(new { message = "Fechas no válidas (aaaa-mm-dd)." });
            }

            return Ok(await _nomregistroService.RetrieveHistoricoAsync(empresa, empleado, desde, hasta, default));
        }

        /// <summary>
        /// Ficha el empleado del TOKEN, el mismo que hizo login (desde PowerBuilder,
        /// el usuario movil que tiene asignado el usuario del ERP). Si el cuerpo
        /// trae otra empresa u otro empleado, 403: nadie ficha por otro.
        /// </summary>
        [HttpPost()]
        [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<bool>> FicharAsync([FromBody] FicharRequest request)
        {
            if (!EmpleadoDelToken(out var empresa, out var empleado)
                || !Texto.Igual(request.Empresa ?? empresa, empresa)
                || !Texto.Igual(request.Empleado ?? empleado, empleado))
            {
                return Forbid();
            }

            bool retorno = true;
            try
            {
                await _nomregistroService.FicharAsync(empresa, empleado, request.Latitud, request.Longitud, default);
                return Ok(retorno);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Borra un fichaje PROPIO (el del token) en los 5 minutos siguientes a
        /// hacerlo, como WebFichar. Si no es suyo, o no existe, 404; si ya pasó
        /// el plazo, 409.
        /// </summary>
        [HttpPost()]
        [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<bool>> BorrarFichajeAsync([FromBody] BorrarFichajeRequest request)
        {
            if (!EmpleadoDelToken(out var empresa, out var empleado)) return Forbid();

            try
            {
                var resultado = await _nomregistroService.BorrarFichajeAsync(request.Id, empresa, empleado, default);
                return resultado switch
                {
                    ResultadoBorrado.Borrado => Ok(true),
                    ResultadoBorrado.FueraDePlazo => Conflict(new
                    {
                        message = $"Un fichaje solo se puede borrar en los {DemoConstants.MinutosParaBorrar} minutos siguientes a hacerlo."
                    }),
                    _ => NoEsTuyo(request.Id)
                };
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Empresa y empleado del que hizo login: vienen en el JWT, no se les
        /// pregunta al cliente.
        /// </summary>
        private bool EmpleadoDelToken(out string empresa, out string empleado)
        {
            empresa = User.Empresa() ?? "";
            empleado = User.Empleado() ?? "";
            return empresa.Trim() != "" && empleado.Trim() != "";
        }

        /// <summary>
        /// 404 tanto si no existe como si es de otro: asi no se puede ir probando
        /// numeros para saber que fichajes hay.
        /// </summary>
        private ActionResult NoEsTuyo(int id) =>
            NotFound(new { message = $"No tienes ningún fichaje con el número {id}." });

        public class FicharRequest
        {
            /// <summary>Opcionales: si vienen, tienen que coincidir con los del token.</summary>
            public string? Empresa { get; set; }
            public string? Empleado { get; set; }
            public double Latitud { get; set; }
            public double Longitud { get; set; }
        }

        public class BorrarFichajeRequest
        {
            public int Id { get; set; }
        }




    }
}