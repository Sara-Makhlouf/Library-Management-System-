import * as React from "react";
import { Grid, Box, Paper } from "@mui/material";
import SignInCard from "../../Core/Components/SignInCard";

export default function LoginPage() {
  return (
    <Grid container sx={{ height: "100vh" }}>
      
      {/* The Left Side OF My Page */}
      <Grid
        size={{ xs: 0, sm: 6, md: 7 }}
        sx={{
          display: { xs: "none", sm: "block" },
          backgroundImage: "url('/admin.png')",
          backgroundSize: "contain",
          backgroundRepeat: "no-repeat",
          backgroundPosition: "center",
          backgroundColor: "#f5f3ee",
        }}
      />

      {/* The Right Side OF My Page */}
      <Grid size={{ xs: 12, sm: 6, md: 5 }}>
        <Paper
          elevation={0}
          sx={{
            height: "100%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            background: "#fff",
          }}
        >
          <Box sx={{ width: "80%" }}>
            <SignInCard />
          </Box>
        </Paper>
      </Grid>
    </Grid>
  );
}