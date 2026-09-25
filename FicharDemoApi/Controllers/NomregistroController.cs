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
using System;
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
        [HttpGet("{as_empresa}/{as_empelado}/{as_fecha}")]
        [ProducesResponseType(typeof(IEnumerable<Dw_Import_Nomregistro>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<IEnumerable<Dw_Import_Nomregistro>>> RetrieveAsync(string as_empresa, string as_empelado, string as_fecha)
        {
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
        
        [HttpPost()]
        [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<bool>> FicharAsync([FromBody] FicharRequest request)
        {
            bool retorno = true;
            try
            {
                await _nomregistroService.FicharAsync(request.Empresa, request.Empleado, request.Latitud, request.Longitud, default);
                return Ok(retorno);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
            
        [HttpPost()]
        [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<bool>> CambiarHoraAsync([FromBody] CambiarHoraRequest request)
        {
            bool retorno = true;
            try
            {
                await _nomregistroService.CambiarHoraAsync(request.Id, request.NuevaHora, default);
                return Ok(retorno);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost()]
        [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<bool>> BorrarFichajeAsync([FromBody] BorrarFichajeRequest request)
        {
            bool retorno = true;
            try
            {
                await _nomregistroService.BorrarFichajeAsync(request.Id, default);
                return Ok(retorno);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        public class FicharRequest
        {
            public string Empresa { get; set; }
            public string Empleado { get; set; }
            public double Latitud { get; set; }
            public double Longitud { get; set; }
        }

        public class InsertarRequest
        {
            public string Empresa { get; set; }
            public string Empleado { get; set; }
            public DateTime NuevaFecha { get; set; }
        }

        public class CambiarHoraRequest
        {
            public int Id { get; set; }
            public DateTime NuevaHora { get; set; }
        }

        public class BorrarFichajeRequest
        {
            public int Id { get; set; }
        }




    }
}