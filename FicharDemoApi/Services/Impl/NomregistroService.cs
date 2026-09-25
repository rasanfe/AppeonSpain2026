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
//10-09-2026: NomregistroService.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using SnapObjects.Data;
using DWNet.Data;
using FicharApi.Models;

namespace FicharApi.Services.Impl
{
    public class NomregistroService : INomregistroService
    {
        private readonly DataContext _dataContext;
        
        public NomregistroService(DefaultDataContext dataContext)
        {
            _dataContext = dataContext;
        }


        public async Task<IEnumerable<Dw_Import_Nomregistro>> RetrieveAsync(string as_empresa,string as_empelado,DateTime? adt_fecha, CancellationToken cancellationToken)
		{
			var dataStore = new DataStore<Dw_Import_Nomregistro>(_dataContext);
            
			await dataStore.RetrieveAsync(new object[] { as_empresa, as_empelado, adt_fecha }, cancellationToken);
            
			return dataStore;
		}
        
        public async Task FicharAsync(string empresa, string empleado, double latitud, double longitud, CancellationToken cancellationToken)
        {
            using (var transaction = _dataContext.BeginTransaction())
            {
                const int mode = FicharApi.Config.DemoConstants.ModoFichaje;
                const string procedureName = "fichar";
                
                try
                {
                    // SnapObjects 5.x ya no admite parametros sueltos en un
                    // procedimiento almacenado: hay que envolverlos en ParamValue.
                    // (En la version 4.2 de 2024 bastaba con pasar los valores.)
                    object[] idParams = new object[]
                     {
                        ParamValue.New<string>("empresa",  empresa),
                        ParamValue.New<string>("empleado", empleado),
                        ParamValue.New<int>("mode",        mode),
                        ParamValue.New<double>("latitud",  latitud),
                        ParamValue.New<double>("longitud", longitud)
                     };

                    var rowsAffected = await _dataContext.SqlExecutor.ExecuteProcedureAsync(procedureName, idParams, cancellationToken);
                    
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    throw new Exception($"Error al ejecutar el procedimiento almacenado fichar: {ex.Message}");
                }
            }
        }
        
            
        public async Task CambiarHoraAsync(int id, DateTime nuevaHora, CancellationToken cancellationToken)
        {
            using (var transaction = _dataContext.BeginTransaction())
            {
                try
                {
                    int mode = await GetModeFromIdAsync(id, cancellationToken);

                    if (mode != 32 ) //Insertado lo dejamos como insertado.
                    {
                        mode = 35; // Modificado
                    }
                    
                    // Actualizar Hora
                    var sql = @"UPDATE nomregistro
                                  SET nomregistro.datetime = @Nuevahora,
                                      mode = @mode  
                                WHERE nomregistro.no=@id";

                    object[] parametersUpdate = new object[]
                    {
                        nuevaHora,
                        mode,
                        id
                    };
                    
                    var rowsAffected = await _dataContext.SqlExecutor.ExecuteAsync(sql, parametersUpdate, cancellationToken);
                    
                    // Confirmar la transacción
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    // Deshacer la transacción en caso de error
                    transaction.Rollback();
                    throw new Exception($"Error al actualizar nomregistro: {ex.Message}");
                }
            }

        }

        public async Task BorrarFichajeAsync(int id, CancellationToken cancellationToken)
        {
            using (var transaction = _dataContext.BeginTransaction())
            {
                try
                {
                    // Actualizar Hora
                    var sql = @"DELETE nomregistro
                                     WHERE nomregistro.no=@id";

                    object[] parametersDelete = new object[]
                     {
                        id
                     };

                    var rowsAffected = await _dataContext.SqlExecutor.ExecuteAsync(sql, parametersDelete, cancellationToken);

                    // Confirmar la transacción
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    // Deshacer la transacción en caso de error
                    transaction.Rollback();
                    throw new Exception($"Error al eliminar nomregistro: {ex.Message}");
                }
            }
        }

        private async Task<int> GetModeFromIdAsync(int id, CancellationToken cancellationToken)
        {
             var sql = @"
                    SELECT mode 
                    FROM nomregistro
                    WHERE nomregistro.no = @Id;";

            int mode = await _dataContext.SqlExecutor.ScalarAsync<int>(sql, new object[] { id }, cancellationToken);

            return mode;
        }

        
    }
}