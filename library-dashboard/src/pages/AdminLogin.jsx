import Box from "@mui/material/Box";

import SignInSide from "../Components/SignInSide";

export default function AdminLoginPage() {
  return (
    <Box
      sx={{
        height: "100vh",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",

        backgroundImage:
          "url('/pic1.jpg')",
        backgroundSize: "cover",
        backgroundPosition: "center",

        position: "relative",
      }}
    >
    
      {/* layout */}
    
       <SignInSide  />

       
    </Box>
  );
}