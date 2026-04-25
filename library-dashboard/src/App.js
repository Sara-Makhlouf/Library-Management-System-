import React from 'react';
import { Toaster } from "react-hot-toast";
import AppRouter from './Constants/AppRouter.jsx';
function App() {

return (
<>
  <AppRouter />
<Toaster position="top-right" />

</>

);
}

export default App;