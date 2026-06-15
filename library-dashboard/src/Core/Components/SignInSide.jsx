import CssBaseline from "@mui/material/CssBaseline";
import Stack from "@mui/material/Stack";
import AppTheme from "../shared-theme/AppTheme";
import ColorModeSelect from "../shared-theme/ColorModeSelect";
import SignInCard from "./SignInCard";
import Content from "./Content";

export default function SignInSide(props) {
  return (
    <AppTheme {...props}>
      <CssBaseline enableColorScheme />

      <ColorModeSelect
        sx={{
          position: "fixed",
          top: "1rem",
          right: "1rem",
          zIndex: 10,
          
        }}
      />
      <Stack
        component="main"
        sx={{
          minHeight: "100vh",
          position: "relative",
          overflow: "hidden",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",

          "&::before": {
            content: '""',
            position: "absolute",
            inset: 0,
            background:
              "radial-gradient(circle at 20% 20%, #4facfe33, transparent 40%)," +
              "radial-gradient(circle at 80% 80%, #00f2fe33, transparent 40%)," +
              "linear-gradient(135deg, #0f172a, #1e293b)",
            zIndex: -1,
          },
        }}
      >
        <Stack
          direction={{ xs: "column", md: "row" }}
          sx={{
            width: "100%",
            maxWidth: "1100px",
            alignItems: "center",
            justifyContent: "space-between",
            gap: { xs: 25, md: 30 },
            px: 3,
            py: 6,
          }}
        >
          {/* Left side - Content */}
          <Stack
            sx={{
              flex: 1,
              color: "#fff",
              textAlign: { xs: "center", md: "left" },
              animation: "fadeIn 0.8s ease",
              "@keyframes fadeIn": {
                from: { opacity: 0, transform: "translateY(20px)" },
                to: { opacity: 1, transform: "translateY(0)" },
              },
            }}
          >
            <Content />
          </Stack>

          {/* Right side - Login */}
          <Stack
            sx={{
              flex: 1,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              animation: "fadeIn 1s ease",
            }}
          >
            <SignInCard />
          </Stack>
        </Stack>
      </Stack>
    </AppTheme>
  );
}