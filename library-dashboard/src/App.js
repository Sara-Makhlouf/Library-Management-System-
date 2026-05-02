import React from 'react';
import { Toaster } from "react-hot-toast";
import AppRouter from './Constants/AppRouter.jsx';
import Sidebar from './Components/SideBar.js';
import { useLocation } from "react-router-dom";
import { AuthProvider } from './Context/AuthContext.jsx';

function App() {
  const location = useLocation();

  const hideSidebar = location.pathname === "/";

  return (
    <>
      {!hideSidebar && <Sidebar />}

      <main style={{ minHeight: "100vh", display: "block" }}>
            <AuthProvider>

        <AppRouter />   
         </AuthProvider>


      </main>

      <Toaster position="top-right" />
    </>
  );
}

export default App;

