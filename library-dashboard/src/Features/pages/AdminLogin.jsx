import * as React from "react";
import { useEffect } from "react";
import { Grid, Box, Typography,Paper } from "@mui/material";
import SignInCard from "../../Core/Components/SignInCard";

const BG        = "#FBF7ED"; 
const SURFACE   = "#FFFFFF"; 
const GOLD      = "#c9a84c";
const TEXT      = "#2b2416"; 
const goldA = (a) => `rgba(201,168,76,${a})`;

const FONT_IMPORT_ID = "lib-fonts";
const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (document.getElementById(FONT_IMPORT_ID)) return;
  const link = document.createElement("link");
  link.id = FONT_IMPORT_ID;
  link.rel = "stylesheet";
  link.href = FONT_HREF;
  document.head.appendChild(link);
}

const display = { fontFamily: "'Fraunces', serif" };

export default function LoginPage() {
  useEffect(() => { injectFonts(); }, []);

  return (
    <Grid container sx={{ height: "100vh", bgcolor: BG, fontFamily: "Inter, sans-serif" }}>

      {/* The Left Side OF My Page */}
   <Grid
  size={{ xs: 0, sm: 6, md: 7 }}
  sx={{
    display: { xs: "none", sm: "flex" },
    position: "relative",
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
    background: SURFACE,
  }}
>
<Box
  sx={{
    position: "absolute",
    inset: 0,
    backgroundImage: "url('/admin.png')",
    backgroundSize: "cover",
    backgroundPosition: "center",
    zIndex: 0,
  }}
/>

  <Box
    sx={{
      position: "absolute",
      width: 500,
      height: 500,
      background:
        "radial-gradient(circle, rgba(201,168,76,0.16) 0%, transparent 65%)",
      top: "-120px",
      left: "-120px",
      filter: "blur(10px)",
      zIndex: 1,
    }}
  />

  <Box
    sx={{
      position: "absolute",
      width: 500,
      height: 500,
      background:
        "radial-gradient(circle, rgba(139,94,26,0.12) 0%, transparent 70%)",
      bottom: "-120px",
      right: "-120px",
      filter: "blur(12px)",
      zIndex: 1,
    }}
  />

  <Box
    sx={{
      position: "absolute",
      top: "56px",
      left: "50%",
      transform: "translateX(-50%)",
      zIndex: 2,
      textAlign: "center",
      px: 6,
      maxWidth: 520,

      animation: "showThenHide 9s ease-in-out infinite",
      "@keyframes showThenHide": {
        "0%":   { opacity: 0, transform: "translate(-50%, -14px)" },
        "8%":   { opacity: 1, transform: "translate(-50%, 0)" },
        "63%":  { opacity: 1, transform: "translate(-50%, 0)" },   
        "78%":  { opacity: 0, transform: "translate(-50%, 10px)" },
        "100%": { opacity: 0, transform: "translate(-50%, 10px)" },
      },
    }}
  >
    <Typography
      sx={{
        ...display,
        fontSize: 34,
        fontWeight: 700,
        letterSpacing: -1,
        background:
          `linear-gradient(135deg, ${TEXT} 0%, ${GOLD} 100%)`,
        WebkitBackgroundClip: "text",
        WebkitTextFillColor: "transparent",
        filter: "drop-shadow(0 2px 10px rgba(255,255,255,0.7))",
      }}
    >
      Admin Control Center
    </Typography>

    <Typography
      sx={{
        mt: 1.5,
        fontSize: 14,
        color: TEXT,
        lineHeight: 1.8,
        textShadow: "0 1px 12px rgba(255,255,255,0.85), 0 1px 3px rgba(255,255,255,0.85)",
      }}
    >
      Secure access to your dashboard. Manage users, settings,
      analytics and system configuration from one unified interface.
    </Typography>
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
      zIndex: 2,
    }}
  />
</Grid>
{/** The Right Side of My Page */}
      
      <Grid size={{ xs: 12, sm: 6, md: 5 }}>
        <Paper
          elevation={0}
          sx={{
            height: "100%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            background: BG,
            borderLeft: { sm: `1px solid ${goldA(0.15)}` },
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