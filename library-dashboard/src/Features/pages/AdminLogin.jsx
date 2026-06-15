import * as React from "react";
import { Grid, Box, Typography,Paper } from "@mui/material";
import SignInCard from "../../Core/Components/SignInCard";

const BG = "#0a0a0f";

export default function LoginPage() {
  return (
    <Grid container sx={{ height: "100vh", bgcolor: BG }}>

      {/* The Left Side OF My Page */}
   <Grid
  size={{ xs: 0, sm: 6, md: 7 }}
  sx={{
    display: { xs: "none", sm: "flex" },
    position: "relative",
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
    background: "#111118",
  }}
>
<Box
  sx={{
    position: "absolute",
    inset: 0,
    backgroundImage: "url('/admin.png')",
    backgroundSize: "cover",
    backgroundPosition: "center",
    opacity: 0.12,
    zIndex: 0,
  }}
/>

{/*  Overlay */}
<Box
  sx={{
    position: "absolute",
    inset: 0,
    background:
  "linear-gradient(135deg, rgba(17,17,24,0.55), rgba(17,17,24,0.45))" ,   zIndex: 1,
  }}
/>
  {/* glow */}
  <Box
    sx={{
      position: "absolute",
      width: 500,
      height: 500,
      background:
        "radial-gradient(circle, rgba(201,168,76,0.12) 0%, transparent 65%)",
      top: "-120px",
      left: "-120px",
      filter: "blur(10px)",
    }}
  />

  <Box
    sx={{
      position: "absolute",
      width: 500,
      height: 500,
      background:
        "radial-gradient(circle, rgba(139,94,26,0.10) 0%, transparent 70%)",
      bottom: "-120px",
      right: "-120px",
      filter: "blur(12px)",
    }}
  />

  <Box
    sx={{
      zIndex: 2,
      textAlign: "center",
      px: 6,
      maxWidth: 520,
    }}
  >
    <Typography
      sx={{
        fontSize: 34,
        fontWeight: 800,
        letterSpacing: -1,
        background:
          "linear-gradient(135deg, #ffffff 0%, #c9a84c 100%)",
        WebkitBackgroundClip: "text",
        WebkitTextFillColor: "transparent",
      }}
    >
      Admin Control Center
    </Typography>

    <Typography
      sx={{
        mt: 2,
        fontSize: 14,
        color: "rgba(255,255,255,0.55)",
        lineHeight: 1.8,
      }}
    >
      Secure access to your dashboard. Manage users, settings,
      analytics and system configuration from one unified interface.
    </Typography>

    <Box
      sx={{
        mt: 5,
        display: "grid",
        gridTemplateColumns: "repeat(2, 1fr)",
        gap: 2,
      }}
    >
      {[
        { label: "Security", value: "High" },
        { label: "Uptime", value: "99.9%" },
        { label: "Users", value: "Active" },
        { label: "Status", value: "Online" },
      ].map((item, i) => (
        <Box
          key={i}
          sx={{
            p: 2,
            borderRadius: 3,
            background: "rgba(255,255,255,0.03)",
            border: "1px solid rgba(201,168,76,0.12)",
            backdropFilter: "blur(10px)",
            transition: "0.3s",
            "&:hover": {
              transform: "translateY(-4px)",
              borderColor: "rgba(201,168,76,0.3)",
              boxShadow:
                "0 20px 40px rgba(0,0,0,0.4)",
            },
          }}
        >
          <Typography
            sx={{
              fontSize: 12,
              color: "rgba(255,255,255,0.5)",
            }}
          >
            {item.label}
          </Typography>

          <Typography
            sx={{
              fontSize: 16,
              fontWeight: 700,
              color: "#c9a84c",
              mt: 0.5,
            }}
          >
            {item.value}
          </Typography>
        </Box>
      ))}
    </Box>
  </Box>

  <Box
    sx={{
      position: "absolute",
      bottom: 0,
      left: 0,
      right: 0,
      height: "1px",
      background:
        "linear-gradient(90deg, transparent, rgba(201,168,76,0.4), transparent)",
    }}
  />
</Grid>

      
      <Grid size={{ xs: 12, sm: 6, md: 5 }}>
        <Paper
          elevation={0}
          sx={{
            height: "100%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            background: BG,
            borderLeft: { sm: "1px solid rgba(255,255,255,0.06)" },
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