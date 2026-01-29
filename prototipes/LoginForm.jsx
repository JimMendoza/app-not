import React from "react";
import { Eye, EyeOff } from "lucide-react";
import Btn from "../ui/Btn";

const LoginForm = ({
  paso,
  creds,
  setCreds,
  showP,
  setShowP,
  recordar,
  setRecordar,
  entsFilt,
  sigPaso,
  setPaso,
}) => {
  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-6">
        <div className="flex space-x-2">
          {[1, 2, 3].map((p) => (
            <div
              key={p}
              className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold ${
                paso === p
                  ? "bg-[#910c87] text-white"
                  : paso > p
                    ? "bg-green-500 text-white"
                    : "bg-gray-200 text-gray-500"
              }`}
            >
              {p}
            </div>
          ))}
        </div>
        <span className="text-sm text-gray-600">Paso {paso}/3</span>
      </div>

      {paso === 1 && (
        <div>
          <h2 className="text-xl font-semibold mb-4">Validar Usuario</h2>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            DNI o Usuario
          </label>
          <input
            type="text"
            value={creds.user}
            onChange={(e) => setCreds({ ...creds, user: e.target.value })}
            onKeyPress={(e) => e.key === "Enter" && sigPaso()}
            className="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-[#910c87] mb-4"
            placeholder="Ingrese DNI"
            autoFocus
          />
        </div>
      )}

      {paso === 2 && (
        <div>
          <h2 className="text-xl font-semibold mb-4">Seleccionar Entidad</h2>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Entidad
          </label>
          <select
            value={creds.ent}
            onChange={(e) => setCreds({ ...creds, ent: e.target.value })}
            className="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-[#910c87] mb-4"
            autoFocus
          >
            <option value="">Seleccione</option>
            {entsFilt.map((e) => (
              <option key={e.id} value={e.sig}>
                {e.nom}
              </option>
            ))}
          </select>
          <div className="bg-blue-50 p-3 rounded-lg text-sm text-blue-900">
            <strong>Usuario:</strong> {creds.user}
          </div>
        </div>
      )}

      {paso === 3 && (
        <div>
          <h2 className="text-xl font-semibold mb-4">Ingresar Contraseña</h2>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Contraseña
          </label>
          <div className="relative mb-4">
            <input
              type={showP ? "text" : "password"}
              value={creds.pass}
              onChange={(e) => setCreds({ ...creds, pass: e.target.value })}
              onKeyPress={(e) => e.key === "Enter" && sigPaso()}
              className="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-[#910c87]"
              placeholder="Contraseña"
              autoFocus
            />
            <button
              onClick={() => setShowP(!showP)}
              className="absolute right-3 top-1/2 -translate-y-1/2"
            >
              {showP ? (
                <EyeOff className="w-5 h-5 text-gray-500" />
              ) : (
                <Eye className="w-5 h-5 text-gray-500" />
              )}
            </button>
          </div>
          <div className="bg-blue-50 p-3 rounded-lg text-sm text-blue-900 space-y-1">
            <p>
              <strong>Usuario:</strong> {creds.user}
            </p>
            <p>
              <strong>Entidad:</strong> {creds.ent}
            </p>
          </div>
          <div className="flex items-center mt-4">
            <input
              type="checkbox"
              id="recordar"
              checked={recordar}
              onChange={(e) => setRecordar(e.target.checked)}
              className="w-4 h-4 rounded cursor-pointer"
            />
            <label
              htmlFor="recordar"
              className="ml-2 text-sm text-gray-700 cursor-pointer"
            >
              Recordarme en este dispositivo
            </label>
          </div>
        </div>
      )}

      <div className="flex space-x-3 mt-6">
        {paso > 1 && (
          <button
            onClick={() => setPaso(paso - 1)}
            className="flex-1 px-4 py-3 border rounded-lg hover:bg-gray-50 font-semibold"
          >
            Atrás
          </button>
        )}
        <button
          onClick={sigPaso}
          disabled={
            (paso === 1 && !creds.user) ||
            (paso === 2 && !creds.ent) ||
            (paso === 3 && !creds.pass)
          }
          className={`${
            paso === 1 ? "w-full" : "flex-1"
          } py-3 rounded-lg font-semibold ${
            (paso === 1 && !creds.user) ||
            (paso === 2 && !creds.ent) ||
            (paso === 3 && !creds.pass)
              ? "bg-gray-300 text-gray-500"
              : "bg-[#910c87] text-white hover:bg-[#6d0d67]"
          }`}
        >
          {paso === 3 ? "Ingresar" : "Siguiente"}
        </button>
      </div>
    </div>
  );
};

export default LoginForm;
