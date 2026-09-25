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
//10-09-2026: Dw_Import_Nomregistro.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Runtime.Serialization;
using SnapObjects.Data;
using DWNet.Data;
using Newtonsoft.Json;
using System.Collections;

namespace FicharApi.Models 
{
    [DataWindow("dw_import_nomregistro", DwStyle.Default)]
    [Table("nomregistro")]
    #region DwSelectAttribute  
    [DwSelect("PBSELECT( VERSION(400) TABLE(NAME=\"nomregistro\" ) @(_COLUMNS_PLACEHOLDER_) WHERE(    EXP1 =\"(nomregistro.IOMd\"   OP =\"=\"    EXP2 =\"convert(int, :as_empresa))\"    LOGIC =\"and\" ) WHERE(    EXP1 =\"(:as_empelado is null or nomregistro.EnNo\"   OP =\"=\"    EXP2 =\":as_empelado)\"    LOGIC =\"And\" ) WHERE(    EXP1 =\"(convert(date, nomregistro.DateTime)\"   OP =\"=\"    EXP2 =\"convert(date, :adt_fecha))\" ) ) ARG(NAME = \"as_empresa\" TYPE = string)  ARG(NAME = \"as_empelado\" TYPE = string)  ARG(NAME = \"adt_fecha\" TYPE = datetime)")]
    #endregion
    [DwParameter("as_empresa", typeof(string))]
    [DwParameter("as_empelado", typeof(string))]
    [DwParameter("adt_fecha", typeof(DateTime?))]
    [DwSort("datetime A")]
    [UpdateWhereStrategy(UpdateWhereStrategy.KeyAndConcurrencyCheckColumns)]
    [DwKeyModificationStrategy(UpdateSqlStrategy.DeleteThenInsert)]
    public class Dw_Import_Nomregistro
    {
        [Key]
        [DwColumn("nomregistro", "No")]
        public int No { get; set; }

        [ConcurrencyCheck]
        [DwColumn("nomregistro", "Mchn")]
        public int? Mchn { get; set; }

        [ConcurrencyCheck]
        [DwColumn("nomregistro", "EnNo")]
        public int? Enno { get; set; }

        [ConcurrencyCheck]
        [StringLength(25)]
        [DwColumn("nomregistro", "Name")]
        public string Name { get; set; }

        [ConcurrencyCheck]
        [DwColumn("nomregistro", "Mode")]
        public int? Mode { get; set; }

        [ConcurrencyCheck]
        [DwColumn("nomregistro", "IOMd")]
        public int? Iomd { get; set; }

        [ConcurrencyCheck]
        [DwColumn("nomregistro", "DateTime", TypeName = "datetime")]
        public DateTime? Datetime { get; set; }

        
    }

}



