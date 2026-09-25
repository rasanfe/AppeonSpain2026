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
//10-09-2026: TicketService.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System.Collections.Concurrent;
using System.Security.Cryptography;
using FicharApi.Models;

namespace FicharApi.Services.Impl
{
    /// <summary>
    /// El puente PowerBuilder -> web embebida.
    ///
    /// PowerBuilder ya tiene sesion, asi que pide un ticket y navega a
    /// /sso?t=TICKET. La web lo canja por su propio JWT y el usuario nunca
    /// vuelve a teclear la clave. El ticket es de un solo uso y dura segundos,
    /// asi que no importa que pase por la URL.
    /// </summary>
    public class TicketService : ITicketService
    {
        private sealed record Entrada(Usuarios Usuario, DateTime Caduca);

        private readonly ConcurrentDictionary<string, Entrada> _tickets = new();

        public string Crear(Usuarios usuario, int segundosDeVida)
        {
            Limpiar();
            var ticket = Convert.ToHexString(RandomNumberGenerator.GetBytes(24));
            _tickets[ticket] = new Entrada(usuario, DateTime.UtcNow.AddSeconds(segundosDeVida));
            return ticket;
        }

        public Usuarios? Canjear(string ticket)
        {
            Limpiar();
            // TryRemove: canjear lo consume. Un ticket vale UNA vez.
            if (!_tickets.TryRemove(ticket, out var entrada)) return null;
            if (entrada.Caduca < DateTime.UtcNow) return null;
            return entrada.Usuario;
        }

        private void Limpiar()
        {
            var ahora = DateTime.UtcNow;
            foreach (var par in _tickets)
            {
                if (par.Value.Caduca < ahora) _tickets.TryRemove(par.Key, out _);
            }
        }
    }
}
