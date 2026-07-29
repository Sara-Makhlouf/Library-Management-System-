import * as React from "react";
import { useEffect } from "react";
import {
  Box,
  Button,
  Checkbox,
  Divider,
  FormControlLabel,
  Link,
  TextField,
  Typography,
  CircularProgress,
  IconButton,
  InputAdornment,
} from "@mui/material";

import Visibility from "@mui/icons-material/Visibility";
import VisibilityOff from "@mui/icons-material/VisibilityOff";

import ForgotPassword from "./ForgetPassword";
import { useDispatch, useSelector } from "react-redux";
import loginAdmin from "../Redux/Thunks/AuthThunk";
import { useNavigate } from "react-router-dom";
import { GoogleIcon, FacebookIcon } from "./Cunstom";

const GOLD      = "#c9a84c";
const GOLD_DARK = "#a8822f"; 
const TEXT      = "#2b2416"; 
const inkA = (a) => `rgba(43,36,22,${a})`;
const goldA = (a) => `rgba(201,168,76,${a})`;
const MUTED  = inkA(0.55);
const BORDER = goldA(0.18);

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
const mono    = { fontFamily: "'IBM Plex Mono', monospace" };

const KEYFRAMES = {
  "@keyframes cardPop": {
    "0%":   { opacity: 0, transform: "translateY(24px) scale(0.96)" },
    "100%": { opacity: 1, transform: "translateY(0) scale(1)" },
  },
  "@keyframes fadeSlideUp": {
    from: { opacity: 0, transform: "translateY(14px)" },
    to:   { opacity: 1, transform: "translateY(0)" },
  },
  "@keyframes glowPulse": {
    "0%, 100%": { boxShadow: "0 12px 30px rgba(201,168,76,0.25)" },
    "50%":      { boxShadow: "0 12px 34px rgba(201,168,76,0.4)" },
  },
};

const fadeIn = (delay) => ({
  opacity: 0,
  animation: `fadeSlideUp .55s ${delay}s cubic-bezier(.25,.8,.25,1) both`,
  ...KEYFRAMES,
});

const fieldSx = {
  fontFamily: "Inter, sans-serif",
  "& .MuiInputLabel-root": {
    color: inkA(0.6),
    fontSize: "14px",
    fontWeight: 500,
    fontFamily: "Inter, sans-serif",
  },

  "& .MuiInputLabel-root.Mui-focused": {
    color: GOLD_DARK,
  },

  "& .MuiOutlinedInput-root": {
    borderRadius: "14px",
    color: TEXT,
    bgcolor: goldA(0.05),
    fontFamily: "Inter, sans-serif",
    transition: "all 0.25s ease",

    "& fieldset": {
      borderColor: BORDER,
    },

    "&:hover": {
      bgcolor: goldA(0.08),
    },

    "&:hover fieldset": {
      borderColor: "rgba(201,168,76,0.4)",
    },

    "&.Mui-focused": {
      boxShadow: "0 0 0 4px rgba(201,168,76,0.12)",
    },

    "&.Mui-focused fieldset": {
      borderColor: GOLD,
    },
  },

  "& input": {
    color: TEXT,
  },

  "& .MuiFormHelperText-root": {
    color: "#c8433d",
  },
};

export default function SignInCard() {
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const { loading, error } = useSelector((state) => state.auth);

  const [form, setForm] = React.useState({
    email: "",
    password: "",
  });

  const [errors, setErrors] = React.useState({});
  const [open, setOpen] = React.useState(false);
  const [showPassword, setShowPassword] = React.useState(false);

  useEffect(() => { injectFonts(); }, []);

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value,
    });
  };

  const validate = () => {
    const temp = {};

    if (!/\S+@\S+\.\S+/.test(form.email)) {
      temp.email = "Invalid email";
    }

    if (form.password.length < 6) {
      temp.password = "Min 6 characters";
    }

    setErrors(temp);

    return Object.keys(temp).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validate()) return;

    const result = await dispatch(
      loginAdmin({
        email: form.email,
        password: form.password,
      })
    );

    if (loginAdmin.fulfilled.match(result)) {
      localStorage.setItem("token", result.payload.token);
      navigate("/dashboard");
    }
  };

  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        p: 3,
        position: "relative",
        overflow: "hidden",
        fontFamily: "Inter, sans-serif",
        background: `
          radial-gradient(circle at top left, rgba(201,168,76,0.18), transparent 35%),
          radial-gradient(circle at bottom right, rgba(59,130,246,0.08), transparent 30%),
          linear-gradient(135deg, #FBF7ED 0%, #FFF9EE 50%, #FBF7ED 100%)
        `,
      }}
    >
      <Box
        sx={{
          position: "absolute",
          top: -120,
          left: -120,
          width: 350,
          height: 350,
          borderRadius: "50%",
          background: GOLD,
          filter: "blur(140px)",
          opacity: 0.14,
        }}
      />

      <Box
        sx={{
          position: "absolute",
          bottom: -100,
          right: -80,
          width: 280,
          height: 280,
          borderRadius: "50%",
          background: "#3b82f6",
          filter: "blur(120px)",
          opacity: 0.08,
        }}
      />

      <Box
        sx={{
          width: 420,
          p: 4,
          borderRadius: "28px",
          position: "relative",
          overflow: "hidden",
          zIndex: 1,

          bgcolor: "rgba(255,255,255,0.85)",
          backdropFilter: "blur(24px)",

          border: `1px solid ${goldA(0.2)}`,

          boxShadow: `
            0 20px 80px rgba(43,36,22,0.12),
            0 0 40px rgba(201,168,76,0.1),
            inset 0 1px 0 rgba(255,255,255,0.6)
          `,

          opacity: 0,
          animation: "cardPop .6s cubic-bezier(.22,1,.36,1) both",
          ...KEYFRAMES,
        }}
      >
        <Box
          sx={{
            position: "absolute",
            top: -100,
            right: -80,
            width: 240,
            height: 240,
            background:
              "radial-gradient(circle, rgba(201,168,76,0.14) 0%, transparent 70%)",
            pointerEvents: "none",
          }}
        />

        <Typography
          sx={{
            ...display,
            textAlign: "center",
            fontWeight: 600,
            mb: 1,
            fontSize: 32,
            letterSpacing: "-1px",
            background: `linear-gradient(135deg, ${TEXT} 0%, ${GOLD} 100%)`,
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            ...fadeIn(0.15),
          }}
        >
          Welcome Back
        </Typography>

        <Typography
          sx={{
            textAlign: "center",
            color: MUTED,
            mb: 4,
            fontSize: 14,
            ...fadeIn(0.22),
          }}
        >
          Sign in to continue to your dashboard
        </Typography>

        <Box
          component="form"
          onSubmit={handleSubmit}
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: 2,
          }}
        >
          <Box sx={fadeIn(0.3)}>
            <TextField
              label="Email"
              name="email"
              value={form.email}
              onChange={handleChange}
              error={!!errors.email}
              helperText={errors.email}
              fullWidth
              sx={fieldSx}
            />
          </Box>

          <Box sx={fadeIn(0.37)}>
            <TextField
              label="Password"
              name="password"
              type={showPassword ? "text" : "password"}
              value={form.password}
              onChange={handleChange}
              error={!!errors.password}
              helperText={errors.password}
              fullWidth
              sx={fieldSx}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      onClick={() => setShowPassword(!showPassword)}
                      sx={{
                        color: MUTED,
                        "&:hover": {
                          color: GOLD_DARK,
                        },
                      }}
                    >
                      {showPassword ? (
                        <VisibilityOff />
                      ) : (
                        <Visibility />
                      )}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />
          </Box>

          {error && (
            <Typography
              sx={{
                textAlign: "center",
                color: "#c8433d",
                fontSize: 13.5,
              }}
            >
              {error}
            </Typography>
          )}

          <Link
            component="button"
            onClick={() => setOpen(true)}
            sx={{
              ...mono,
              textAlign: "right",
              fontSize: 12.5,
              fontWeight: 600,
              color: GOLD_DARK,
              textDecoration: "none",
              ...fadeIn(0.44),

              "&:hover": {
                color: GOLD,
              },
            }}
          >
            Forgot password?
          </Link>

          <FormControlLabel
            control={
              <Checkbox
                sx={{
                  color: MUTED,
                  "&.Mui-checked": {
                    color: GOLD_DARK,
                  },
                }}
              />
            }
            label="Remember me"
            sx={{
              ...fadeIn(0.5),
              "& .MuiFormControlLabel-label": {
                fontSize: 13.5,
                color: inkA(0.72),
                fontFamily: "Inter, sans-serif",
              },
            }}
          />

          <ForgotPassword
            open={open}
            handleClose={() => setOpen(false)}
          />

          <Button
            type="submit"
            fullWidth
            variant="contained"
            disableElevation
            disabled={loading}
            sx={{
              py: 1.4,
              borderRadius: "14px",
              fontWeight: 700,
              textTransform: "none",
              fontSize: 15,
              fontFamily: "Inter, sans-serif",

              color: "#111",

              background: `linear-gradient(135deg, #e7c96a 0%, ${GOLD} 100%)`,

              animation: "fadeSlideUp .55s .58s cubic-bezier(.25,.8,.25,1) both, glowPulse 2.8s ease-in-out 1.2s infinite",
              opacity: 0,
              ...KEYFRAMES,

              transition: "transform 0.25s ease, box-shadow 0.25s ease",

              "&:hover": {
                transform: "translateY(-2px)",
                boxShadow: "0 18px 40px rgba(201,168,76,0.35)",
              },

              "&:disabled": {
                opacity: 0.7,
                color: "#111",
              },
            }}
          >
            {loading ? (
              <CircularProgress
                size={22}
                sx={{ color: "#111" }}
              />
            ) : (
              "Sign in"
            )}
          </Button>
        </Box>

        <Divider
          sx={{
            ...mono,
            my: 3,
            borderColor: BORDER,
            color: MUTED,
            fontSize: 11,
            letterSpacing: 0.3,
            ...fadeIn(0.65),
          }}
        >
          or continue with
        </Divider>

        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: 1.5,
            ...fadeIn(0.72),
          }}
        >
          <Button
            fullWidth
            variant="outlined"
            startIcon={<GoogleIcon />}
            sx={{
              borderRadius: "14px",
              py: 1.2,
              textTransform: "none",
              fontWeight: 600,
              fontSize: 13.5,
              fontFamily: "Inter, sans-serif",

              color: TEXT,

              bgcolor: goldA(0.05),
              backdropFilter: "blur(10px)",

              border: `1px solid ${goldA(0.18)}`,

              transition: "all 0.25s ease",

              "&:hover": {
                bgcolor: goldA(0.09),
                borderColor: "rgba(201,168,76,0.3)",
                transform: "translateY(-2px)",
                color: TEXT,
              },
            }}
          >
            Continue with Google
          </Button>

          <Button
            fullWidth
            variant="outlined"
            startIcon={<FacebookIcon />}
            sx={{
              borderRadius: "14px",
              py: 1.2,
              textTransform: "none",
              fontWeight: 600,
              fontSize: 13.5,
              fontFamily: "Inter, sans-serif",

              color: TEXT,

              bgcolor: goldA(0.05),
              backdropFilter: "blur(10px)",

              border: `1px solid ${goldA(0.18)}`,

              transition: "all 0.25s ease",

              "&:hover": {
                bgcolor: goldA(0.09),
                borderColor: "rgba(201,168,76,0.3)",
                transform: "translateY(-2px)",
                color: TEXT,
              },
            }}
          >
            Continue with Facebook
          </Button>
        </Box>
      </Box>
    </Box>
  );
}