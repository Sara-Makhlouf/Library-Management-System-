import * as React from "react";
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

const SURFACE = "#111118";
const GOLD    = "#c9a84c";
const GOLD2   = "#8b5e1a";
const BORDER  = "rgba(255,255,255,0.06)";
const BORDER2 = "rgba(255,255,255,0.10)";
const TEXT    = "#fff";
const MUTED   = "rgba(255,255,255,0.35)";
const fieldSx = {
  "& .MuiInputLabel-root": {
    color: "#C5BC35",
    fontSize: "15px",
    fontWeight: 600,
  },

  "& .MuiInputLabel-root.Mui-focused": {
    color: "#f0c75e",
  },

  "& .MuiOutlinedInput-root": {
    borderRadius: "12px",
    color: "#fff",
    bgcolor: "rgba(255,255,255,0.05)",

    "& fieldset": {
      borderColor: "rgba(255,255,255,0.1)",
    },

    "&:hover fieldset": {
      borderColor: "rgba(212,175,55,0.4)",
    },

    "&.Mui-focused fieldset": {
      borderColor: "#d4af37",
    },
  },

  "& input": {
    color: "#fff",
  },
};
export default function SignInCard() {
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const { loading, error } = useSelector((state) => state.auth);

  const [form, setForm] = React.useState({ email: "", password: "" });
  const [errors, setErrors] = React.useState({});
  const [open, setOpen] = React.useState(false);
  const [showPassword, setShowPassword] = React.useState(false);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validate = () => {
    let temp = {};
    if (!/\S+@\S+\.\S+/.test(form.email)) temp.email = "Invalid email";
    if (form.password.length < 6) temp.password = "Min 6 characters";
    setErrors(temp);
    return Object.keys(temp).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;

    const result = await dispatch(loginAdmin({ email: form.email, password: form.password }));
    console.log("LOGIN RESULT:", result);

    if (loginAdmin.fulfilled.match(result)) {
      localStorage.setItem("token", result.payload.token); // 🔥 مهم جدًا
      navigate("/dashboard");
    }
  };

  return (
    <Box sx={{ display: "flex", justifyContent: "center", alignItems: "center", minHeight: "100vh" }}>
      <Box
        sx={{
          width: 420,
          p: 4,
          borderRadius: "20px",
          bgcolor: SURFACE,
          border: "1px solid rgba(201,168,76,0.15)",
          boxShadow: "0 40px 80px rgba(0,0,0,0.5)",
          position: "relative",
          overflow: "hidden",
          fontFamily: "Inter, sans-serif",
        }}
      >
        <Box sx={{ position: "absolute", top: -100, right: -80, width: 260, height: 260, background: "radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

        <Typography
          sx={{
            textAlign: "center", fontWeight: 800, mb: 3,
            fontSize: 24, letterSpacing: -0.5,
            background: `linear-gradient(135deg,${TEXT} 0%,${GOLD} 100%)`,
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text",
          }}
        >
          Welcome Back
        </Typography>

        <Box component="form" onSubmit={handleSubmit} sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
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
                    sx={{ color: MUTED, "&:hover": { color: GOLD } }}
                  >
                    {showPassword ? <VisibilityOff /> : <Visibility />}
                  </IconButton>
                </InputAdornment>
              ),
            }}
          />

          {error && (
            <Typography sx={{ textAlign: "center", color: "#f87171", fontSize: 13.5 }}>
              {error}
            </Typography>
          )}

          <Link
            component="button"
            onClick={() => setOpen(true)}
            sx={{
              textAlign: "right", fontSize: 13.5,
              color: GOLD, textDecorationColor: "rgba(255,255,255,0.2)",
            }}
          >
            Forgot password?
          </Link>

          <FormControlLabel
            control={
              <Checkbox
                sx={{
                  color: MUTED,
                  "&.Mui-checked": { color: GOLD },
                }}
              />
            }
            label="Remember me"
            sx={{ "& .MuiFormControlLabel-label": { fontSize: 13.5, color: "rgba(255,255,255,0.7)" } }}
          />

          <ForgotPassword open={open} handleClose={() => setOpen(false)} />

          <Button
            type="submit"
            fullWidth
            variant="contained"
            disableElevation
            disabled={loading}
            sx={{
              py: 1.3, borderRadius: "12px",
              fontWeight: 700, textTransform: "none", fontSize: 14,
              color: "#fff",
              background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
              "&:hover": {
                background: "linear-gradient(135deg,#d4b562,#9e6c20)",
                transform: "translateY(-1px)",
                boxShadow: "0 12px 28px rgba(201,168,76,0.25)",
              },
              "&:disabled": { opacity: 0.6, color: "#fff" },
              transition: "all 0.25s",
            }}
          >
            {loading ? <CircularProgress size={22} sx={{ color: "#fff" }} /> : "Sign in"}
          </Button>
        </Box>

        <Divider sx={{ my: 2.5, borderColor: BORDER, color: MUTED, fontSize: 12.5 }}>or</Divider>

        <Box sx={{ display: "flex", flexDirection: "column", gap: 1.5 }}>
          <Button
            fullWidth
            variant="outlined"
            startIcon={<GoogleIcon />}
            sx={{
              borderRadius: "12px", py: 1.2,
              textTransform: "none", fontWeight: 600, fontSize: 13.5,
              color: TEXT,
              border: `1px solid ${BORDER2}`,
              bgcolor: "rgba(255,255,255,0.03)",
              transition: "all 0.25s",
              "&:hover": {
                bgcolor: "rgba(201,168,76,0.08)",
                borderColor: `${GOLD}50`,
                transform: "translateY(-2px)",
                boxShadow: `0 8px 25px rgba(201,168,76,0.15)`,
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
              borderRadius: "12px", py: 1.2,
              textTransform: "none", fontWeight: 600, fontSize: 13.5,
              color: TEXT,
              border: `1px solid ${BORDER2}`,
              bgcolor: "rgba(255,255,255,0.03)",
              transition: "all 0.25s",
              "&:hover": {
                bgcolor: "rgba(201,168,76,0.08)",
                borderColor: `${GOLD}50`,
                transform: "translateY(-2px)",
                boxShadow: `0 8px 25px rgba(201,168,76,0.15)`,
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