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

const GOLD = "#c9a84c";
const TEXT = "#ffffff";
const MUTED = "rgba(255,255,255,0.45)";
const BORDER = "rgba(255,255,255,0.08)";

const fieldSx = {
  "& .MuiInputLabel-root": {
    color: "rgba(255,255,255,0.55)",
    fontSize: "14px",
    fontWeight: 500,
  },

  "& .MuiInputLabel-root.Mui-focused": {
    color: GOLD,
  },

  "& .MuiOutlinedInput-root": {
    borderRadius: "14px",
    color: "#fff",
    bgcolor: "rgba(255,255,255,0.04)",
    transition: "all 0.25s ease",

    "& fieldset": {
      borderColor: BORDER,
    },

    "&:hover": {
      bgcolor: "rgba(255,255,255,0.06)",
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
    color: "#fff",
  },

  "& .MuiFormHelperText-root": {
    color: "#f87171",
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
        background: `
          radial-gradient(circle at top left, rgba(201,168,76,0.15), transparent 35%),
          radial-gradient(circle at bottom right, rgba(59,130,246,0.10), transparent 30%),
          linear-gradient(135deg, #08080c 0%, #0f0f15 50%, #09090d 100%)
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
          opacity: 0.12,
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

          bgcolor: "rgba(17,17,24,0.75)",
          backdropFilter: "blur(24px)",

          border: "1px solid rgba(255,255,255,0.08)",

          boxShadow: `
            0 20px 80px rgba(0,0,0,0.5),
            0 0 40px rgba(201,168,76,0.08),
            inset 0 1px 0 rgba(255,255,255,0.06)
          `,
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
              "radial-gradient(circle, rgba(201,168,76,0.10) 0%, transparent 70%)",
            pointerEvents: "none",
          }}
        />

        <Typography
          sx={{
            textAlign: "center",
            fontWeight: 800,
            mb: 1,
            fontSize: 32,
            letterSpacing: "-1px",
            background: `linear-gradient(135deg, #ffffff 0%, ${GOLD} 100%)`,
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
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
                    sx={{
                      color: MUTED,
                      "&:hover": {
                        color: GOLD,
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

          {error && (
            <Typography
              sx={{
                textAlign: "center",
                color: "#f87171",
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
              textAlign: "right",
              fontSize: 13.5,
              color: GOLD,
              textDecoration: "none",

              "&:hover": {
                color: "#e7c96a",
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
                    color: GOLD,
                  },
                }}
              />
            }
            label="Remember me"
            sx={{
              "& .MuiFormControlLabel-label": {
                fontSize: 13.5,
                color: "rgba(255,255,255,0.7)",
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

              color: "#111",

              background: `linear-gradient(135deg, #e7c96a 0%, ${GOLD} 100%)`,

              boxShadow: "0 12px 30px rgba(201,168,76,0.25)",

              transition: "all 0.3s ease",

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
            my: 3,
            borderColor: BORDER,
            color: MUTED,
            fontSize: 12.5,
          }}
        >
          or continue with
        </Divider>

        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: 1.5,
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

              color: TEXT,

              bgcolor: "rgba(255,255,255,0.04)",
              backdropFilter: "blur(10px)",

              border: "1px solid rgba(255,255,255,0.08)",

              transition: "all 0.25s ease",

              "&:hover": {
                bgcolor: "rgba(255,255,255,0.07)",
                borderColor: "rgba(201,168,76,0.25)",
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

              color: TEXT,

              bgcolor: "rgba(255,255,255,0.04)",
              backdropFilter: "blur(10px)",

              border: "1px solid rgba(255,255,255,0.08)",

              transition: "all 0.25s ease",

              "&:hover": {
                bgcolor: "rgba(255,255,255,0.07)",
                borderColor: "rgba(201,168,76,0.25)",
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