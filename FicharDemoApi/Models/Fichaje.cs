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
//17-10-2026: Fichaje.cs
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
    /// Un fichaje tal y como lo recibe la web: el mismo contrato que daba el
    /// DataWindow de 2024, en PascalCase (por eso los nombres van fijados) y
    /// sin el GPS, que se graba pero no sale de la API.
    /// </summary>
    public class Fichaje
    {
        [JsonPropertyName("No")]
        public int No { get; set; }

        [JsonPropertyName("Mchn")]
        public int? Mchn { get; set; }

        [JsonPropertyName("Enno")]
        public int? Enno { get; set; }

        [JsonPropertyName("Name")]
        public string? Name { get; set; }

        [JsonPropertyName("Mode")]
        public int? Mode { get; set; }

        [JsonPropertyName("Iomd")]
        public int? Iomd { get; set; }

        [JsonPropertyName("Datetime")]
        public DateTime? Datetime { get; set; }

        public static Fichaje Desde(Nomregistro fila) => new()
        {
            No = fila.No,
            Mchn = fila.Mchn,
            Enno = fila.EnNo,
            Name = fila.Name,
            Mode = fila.Mode,
            Iomd = fila.IOMd,
            Datetime = fila.Fecha
        };
    }
}
