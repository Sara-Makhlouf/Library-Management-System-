import * as React from "react";
import {
  Box,
  Button,
  Card,
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
import{ COLORS} from "../Constants/ColorsUse";
import ForgotPassword from "./ForgetPassword";
import { useDispatch, useSelector } from "react-redux";
import loginAdmin from "../Redux/Thunks/AuthThunk";
import { useNavigate } from "react-router-dom";
import { GoogleIcon, FacebookIcon } from "./Cunstom";

export default function SignInCard() {
  const navigate = useNavigate();
const dispatch = useDispatch();

const { loading, error } = useSelector(
  (state) => state.auth
);
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
    let temp = {};

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
console.log("LOGIN RESULT:", result);
  if (loginAdmin.fulfilled.match(result)) {
    navigate("/dashboard");
  }
};

  return (
    <Box
      sx={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        minHeight: "100vh",
      }}
    >
      <Card
        sx={{
          width: 420,
          p: 4,
          borderRadius: 4,
          background: "rgba(255, 255, 255, 0.08)",
          backdropFilter: "blur(18px)",
          border: "1px solid rgba(236, 227, 51, 0.15)",
          boxShadow: "0 25px 60px rgba(0,0,0,0.35)",
        }}
      >
        <Typography
          variant="h5"
          sx={{ textAlign: "center", fontWeight: 700, mb: 3 ,color: COLORS.Secondary}}
        >
          Welcome Back
        </Typography>

        <Box
          component="form"
          onSubmit={handleSubmit} //ح اتركا هيك بس كرمال التحريب
          sx={{ display: "flex", flexDirection: "column", gap: 2 }}
        >
          <TextField
            label="email"
            name="email"
            value={form.email}
            onChange={handleChange}
            error={!!errors.email}
            helperText={errors.email}
            fullWidth
             sx={{
      
    "& .MuiInputLabel-root.Mui-focused": {
      color: COLORS.Primary,
    },
    "& .MuiInputLabel-root.Mui-error": {
      color: "red",
    },
    "& .MuiOutlinedInput-root": {
      "& fieldset": {
        borderColor: COLORS.Accent,
      },
      "&:hover fieldset": {
        borderColor: COLORS.Primary,
      },
      "&.Mui-focused fieldset": {
        borderColor: COLORS.Primary,
      },
    },
  }}
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
             sx={{
   
    "& .MuiInputLabel-root.Mui-focused": {
      color: COLORS.Primary,
    },
    "& .MuiInputLabel-root.Mui-error": {
      color: "red",
    },
    "& .MuiOutlinedInput-root": {
      "& fieldset": {
        borderColor: COLORS.Accent,
      },
      "&:hover fieldset": {
        borderColor: COLORS.Primary,
      },
      "&.Mui-focused fieldset": {
        borderColor: COLORS.Primary, 
      },
    },
  }}
            InputProps={{
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? <VisibilityOff /> : <Visibility />}
                  </IconButton>
                </InputAdornment>
              ),
            }}
          />
{error && (
  <Typography
    color="error"
    sx={{ textAlign: "center" }}
  >
    {error}
  </Typography>
)}
          <Link
            component="button"
            onClick={() => setOpen(true)}
            sx={{ textAlign: "right", 
              color: COLORS.Primary,
                  textDecorationColor: "gray", 

            }}
          >
            Forgot password?
          </Link>

          <FormControlLabel control={<Checkbox />} label="Remember me" />

          <ForgotPassword open={open} handleClose={() => setOpen(false)} />

          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="white"
          onClick={()=>{

          }}
            disabled={loading}
            sx={{ py: 1.3, borderRadius: 3, fontWeight: 600 ,  backgroundColor: COLORS.Primary}}
          >
            {loading ? (
              <CircularProgress size={22}  />
            ) : (
              "Sign in"
            )}
          </Button>
        </Box>

        <Divider sx={{ my: 2 }}>or</Divider>

    <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
  <Button
    fullWidth
    variant="outlined"
    startIcon={<GoogleIcon />}
    sx={{
      borderRadius: 3,
      py: 1.2,

      color: "#fff",
      border: "1px solid rgba(255,255,255,0.2)",
      backgroundColor: COLORS.Secondary,
      backdropFilter: "blur(10px)",

      transition: "0.3s ease",

      "&:hover": {
        background: "rgba(128, 2, 2, 0.1)",
        borderColor: COLORS.Primary,
        transform: "translateY(-2px)",
        boxShadow: `0 8px 25px ${COLORS.Primary}33`,
        color: "black"
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
      borderRadius: 3,
      py: 1.2,

      color: "#fff",
      border: "1px solid rgba(255,255,255,0.2)",
      backgroundColor: COLORS.Secondary,
      backdropFilter: "blur(10px)",

      transition: "0.3s ease",

      "&:hover": {
         background: "rgba(128, 2, 2, 0.1)",
        borderColor: COLORS.Primary,
        transform: "translateY(-2px)",
        boxShadow: `0 8px 25px ${COLORS.Primary}33`,
        color: "black"
      },
    }}
  >
    Continue with Facebook
  </Button>
</Box>
      </Card>
    </Box>
  );
}
