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
//10-09-2026: Usuarios.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System;
using System.Text.Json.Serialization;


namespace FicharApi.Models
{
    /// <summary>Una fila de Database/usuarios_mobile.json: quien puede entrar y con que PIN.</summary>
    public class Usuarios
    {
        [JsonPropertyName("Usuario")]
        public string? Usuario { get; set; }

        [JsonPropertyName("Pin")]
        public string? Pin { get; set; }

        [JsonPropertyName("empresa")]
        public string? Empresa { get; set; }

        [JsonPropertyName("empleado")]
        public string? Empleado { get; set; }

        [JsonPropertyName("grupo")]
        public string? Grupo { get; set; }


        [JsonPropertyName("activo")]
        public bool? Activo { get; set; }

        // --- No son columnas de la tabla ---

        [JsonIgnore]
        public string? ConnectionID { get; set; }


        [JsonIgnore]
        public bool IsValid { get; set; }

        [JsonIgnore]
        public string? Token { get; set; }

        [JsonIgnore]
        public DateTime Expiration { get; set; }

    }

}



