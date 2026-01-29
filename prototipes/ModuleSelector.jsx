import React from "react";
import { FileText, Bell, User } from "lucide-react";

const ModuleSelector = ({
  setModulo,
  setVista,
  setFiltro,
  setTramSelNotif,
  noLeidas,
  usuario,
}) => {
  return (
    <div className="relative min-h-screen bg-gradient-to-br from-[#910c87] via-[#6d0d67] to-[#4a0945] flex justify-center items-center p-4 md:p-8">
      <div className="w-full max-w-md md:max-w-2xl">
        <div className="mb-6 md:mb-8">
          <div className="flex items-center gap-4 md:gap-5 px-5 md:px-7 py-4 md:py-5 rounded-2xl bg-white/15 backdrop-blur-md border border-white/20 shadow-xl w-full hover:bg-white/20 transition-all duration-300">
            <div className="w-16 h-16 md:w-20 md:h-20 bg-gradient-to-br from-white to-gray-100 rounded-full flex items-center justify-center shadow-lg flex-shrink-0">
              <User className="w-8 h-8 md:w-10 md:h-10 text-[#910c87]" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-white font-black text-2xl md:text-3xl leading-tight truncate drop-shadow-md">
                {`¡Hola${usuario && usuario.user ? `, ${usuario.user}` : ""}!`}
              </div>
              <div className="text-white/90 text-base md:text-lg font-medium mt-1">
                Selecciona un módulo para comenzar
              </div>
            </div>
          </div>
        </div>
        <div className="bg-white p-6 md:p-8 rounded-3xl shadow-2xl border border-gray-100">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <button
              className="w-full bg-gradient-to-r from-[#910c87] to-[#6d0d67] text-white py-5 md:py-6 rounded-2xl font-bold text-base md:text-lg flex items-center justify-center gap-3 md:gap-4 shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-[#910c87]/50"
              onClick={() => {
                setModulo("tramite");
                setVista("consulta");
              }}
            >
              <FileText className="w-6 h-6 md:w-7 md:h-7" />
              Mesa de Partes Virtual
            </button>
            <button
              className="w-full bg-gradient-to-r from-[#910c87] to-[#6d0d67] text-white py-5 md:py-6 rounded-2xl font-bold text-base md:text-lg flex items-center justify-center gap-3 md:gap-4 shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-[#910c87]/50 relative"
              onClick={() => {
                setModulo("notificaciones");
                setVista("notificaciones");
                setFiltro("nuevas");
                setTramSelNotif(null);
              }}
            >
              <Bell className="w-6 h-6 md:w-7 md:h-7" />
              Notificaciones
              {noLeidas > 0 && (
                <span className="absolute top-2 md:top-3 right-2 md:right-3 w-6 h-6 md:w-7 md:h-7 bg-yellow-400 text-blue-900 text-xs md:text-sm rounded-full flex items-center justify-center font-bold">
                  {noLeidas}
                </span>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ModuleSelector;
