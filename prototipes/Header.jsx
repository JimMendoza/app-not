import React from "react";
import { FileText, Bell, LogOut } from "lucide-react";
import Btn from "../ui/Btn";

const Header = ({ usuario, noLeidas, onNotificationsClick, onLogout }) => {
  return (
    <header className="fixed top-0 left-0 right-0 bg-gradient-to-r from-[#910c87] to-[#6d0d67] shadow-lg z-40">
      <div className="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
        <div className="flex items-center space-x-3">
          <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center">
            <FileText className="w-7 h-7 text-[#910c87]" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-white">AppSIR</h1>
            <p className="text-sm text-red-100">"Mensaje"</p>
          </div>
        </div>
        <div className="flex items-center space-x-4">
          <div className="text-right mr-4 hidden md:block">
            <p className="text-white font-medium text-sm">{usuario.user}</p>
            <p className="text-xs text-red-100">{usuario.ent}</p>
          </div>
          <button
            onClick={onNotificationsClick}
            className="relative p-2 text-white hover:bg-red-800 rounded-lg"
          >
            <Bell className="w-6 h-6" />
            {noLeidas > 0 && (
              <span className="absolute -top-1 -right-1 w-5 h-5 bg-yellow-400 text-red-900 text-xs rounded-full flex items-center justify-center font-bold">
                {noLeidas}
              </span>
            )}
          </button>
          <Btn
            onClick={onLogout}
            variant="accent"
            className="flex items-center space-x-2"
          >
            <LogOut className="w-5 h-5" />
            <span className="hidden md:inline">Salir</span>
          </Btn>
        </div>
      </div>
    </header>
  );
};

export default Header;
