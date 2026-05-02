import * as React from "react";
import {
  Box,
  Button,
  Card,
  Checkbox,
  Divider,
  FormLabel,
  FormControl,
  FormControlLabel,
  Link,
  TextField,
  Typography,
  CircularProgress,
} from "@mui/material";

import ForgotPassword from "../Components/ForgetPassword";
import { useAuth } from "../Context/AuthContext";
import { useNavigate } from "react-router-dom";
import {
  GoogleIcon,
  FacebookIcon,
} from "../Components/Cunstom";

export default function SignInCard() {
  const { login } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = React.useState({
    email: "",
    password: "",
  });

  const [errors, setErrors] = React.useState({});
  const [loading, setLoading] = React.useState(false);
  const [open, setOpen] = React.useState(false);

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

    try {
      setLoading(true);

      await login(form.email, form.password);

      navigate("/dashboard");
    } catch (err) {
      setErrors({
        password:
          err.response?.data?.message || "Login failed",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <Card
        sx={{
          width: 420,
          p: 4,
          borderRadius: 4,
         background: "rgba(255, 255, 255, 0.08)",
    backdropFilter: "blur(18px)",
    border: "1px solid rgba(255, 255, 255, 0.15)",

    boxShadow: "0 25px 60px rgba(0,0,0,0.35)",
        
        }}
      >
      

        {/* Title */}
        <Typography
          variant="h5"
          sx={{ textAlign: "center", fontWeight: 700, mb: 2 }}
        >
          Welcome Back
        </Typography>

        {/* Form */}
        <Box
          component="form"
          onSubmit={handleSubmit}
          sx={{ display: "flex", flexDirection: "column", gap: 2 }}
        >
          {/* Email */}
          <FormControl>
            <FormLabel>Email</FormLabel>
            <TextField
              name="email"
              value={form.email}
              onChange={handleChange}
              error={!!errors.email}
              helperText={errors.email}
              fullWidth
            />
          </FormControl>

          {/* Password */}
          <FormControl>
            <FormLabel>Password</FormLabel>

            <TextField
              name="password"
              type="password"
              value={form.password}
              onChange={handleChange}
              error={!!errors.password}
              helperText={errors.password}
              fullWidth
            />

            <Link
              component="button"
              onClick={() => setOpen(true)}
              sx={{ mt: 1, textAlign: "right" }}
            >
              Forgot password?
            </Link>
          </FormControl>

          <FormControlLabel
            control={<Checkbox />}
            label="Remember me"
          />

          <ForgotPassword open={open} handleClose={() => setOpen(false)} />

          {/* Submit */}
          <Button
            type="submit"
            fullWidth
            variant="contained"
            disabled={loading}
            sx={{
              py: 1.3,
              borderRadius: 3,
              fontWeight: 600,
            }}
          >
            {loading ? (
              <CircularProgress size={22} color="inherit" />
            ) : (
              "Sign in"
            )}
          </Button>

          
        </Box>

        <Divider sx={{ my: 2 }}>or</Divider>

        {/* Social */}
        <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
          <Button fullWidth variant="outlined" startIcon={<GoogleIcon />}>
            Continue with Google
          </Button>

          <Button fullWidth variant="outlined" startIcon={<FacebookIcon />}>
            Continue with Facebook
          </Button>
        </Box>
      </Card>
    </Box>
  );
}