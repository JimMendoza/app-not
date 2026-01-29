import React from "react";
import { FileText, Lock } from "lucide-react";
import LoginForm from "./LoginForm";

const LoginPage = ({
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
    <div className="min-h-screen bg-gradient-to-br from-blue-900 to-blue-800 flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-2xl">
        <div className="bg-gradient-to-r from-[#910c87] to-[#6d0d67] p-8 text-center">
          <div className="w-20 h-20 bg-white rounded-full mx-auto mb-4 flex items-center justify-center">
            <FileText className="w-10 h-10 text-[#128C7E]" />
          </div>
          <h1 className="text-3xl font-bold text-white">AppSIR</h1>
          <p className="text-red-100">"Mensaje"</p>
        </div>

        <LoginForm
          paso={paso}
          creds={creds}
          setCreds={setCreds}
          showP={showP}
          setShowP={setShowP}
          recordar={recordar}
          setRecordar={setRecordar}
          entsFilt={entsFilt}
          sigPaso={sigPaso}
          setPaso={setPaso}
        />

        <div className="px-8 pb-8">
          <div className="pt-6 border-t flex items-center justify-center space-x-2 text-sm text-gray-600">
            <Lock className="w-4 h-4" />
            <span>Seguro SSL</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
