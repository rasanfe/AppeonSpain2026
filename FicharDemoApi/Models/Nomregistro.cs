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
//17-10-2026: Nomregistro.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System.Text.Json.Serialization;

namespace FicharApi.Models
{
    /// <summary>
    /// Una fila de Database/nomregistro.json: un fichaje, con las columnas de la
    /// tabla del ERP. Entrada y salida NO se guardan: se deducen del orden
    /// dentro del dia, igual que en el ERP.
    /// </summary>
    public class Nomregistro
    {
        [JsonPropertyName("No")]
        public int No { get; set; }

        [JsonPropertyName("Mchn")]
        public int? Mchn { get; set; }

        [JsonPropertyName("EnNo")]
        public int? EnNo { get; set; }

        [JsonPropertyName("Name")]
        public string? Name { get; set; }

        [JsonPropertyName("Mode")]
        public int? Mode { get; set; }

        /// <summary>La empresa, en numero.</summary>
        [JsonPropertyName("IOMd")]
        public int? IOMd { get; set; }

        [JsonPropertyName("DateTime")]
        public DateTime? Fecha { get; set; }

        [JsonPropertyName("latitud")]
        public double? Latitud { get; set; }

        [JsonPropertyName("longitud")]
        public double? Longitud { get; set; }
    }
}
