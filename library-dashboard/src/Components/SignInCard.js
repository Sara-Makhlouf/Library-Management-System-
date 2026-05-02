import * as React from "react";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import MuiCard from "@mui/material/Card";
import Checkbox from "@mui/material/Checkbox";
import Divider from "@mui/material/Divider";
import FormLabel from "@mui/material/FormLabel";
import FormControl from "@mui/material/FormControl";
import FormControlLabel from "@mui/material/FormControlLabel";
import Link from "@mui/material/Link";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { styled } from "@mui/material/styles";
import ForgotPassword from "../Components/ForgetPassword";
import { useAuth } from "../Context/AuthContext";
import { useNavigate } from "react-router-dom";
import {
  GoogleIcon,
  FacebookIcon,
  SitemarkIcon,
} from "../Components/Cunstom";

const Card = styled(MuiCard)(({ theme }) => ({
  display: "flex",
  flexDirection: "column",
  width: "100%",
  padding: theme.spacing(4),
  gap: theme.spacing(2),
  borderRadius: 16,

  background: "rgba(255,255,255,0.85)",
  backdropFilter: "blur(12px)",

  boxShadow: "0 20px 50px rgba(0,0,0,0.2)",

  [theme.breakpoints.up("sm")]: {
    width: "450px",
  },
}));

export default function SignInCard() {
  const [emailError, setEmailError] = React.useState(false);
  const [emailErrorMessage, setEmailErrorMessage] = React.useState("");
  const [passwordError, setPasswordError] = React.useState(false);
  const [passwordErrorMessage, setPasswordErrorMessage] =
    React.useState("");
  const [open, setOpen] = React.useState(false);

  const handleClickOpen = () => setOpen(true);
  const handleClose = () => setOpen(false);
const { login } = useAuth();
const navigate = useNavigate();
// handl with login api form //
const handleSubmit = async (event) => {
  event.preventDefault();

  if (!validateInputs()) return;

  const data = new FormData(event.currentTarget);

  try {
    await login(data.get("email"), data.get("password"));

    navigate("/dashboard"); // بعد النجاح

  } catch (err) {
    setEmailError(true);
    setPasswordError(true);
    setPasswordErrorMessage(
      err.response?.data?.message || "Login failed"
    );
  }
};

  const validateInputs = () => {
    const email = document.getElementById("email");
    const password = document.getElementById("password");

    let isValid = true;

    if (!email.value || !/\S+@\S+\.\S+/.test(email.value)) {
      setEmailError(true);
      setEmailErrorMessage("Please enter a valid email address.");
      isValid = false;
    } else {
      setEmailError(false);
      setEmailErrorMessage("");
    }

    if (!password.value || password.value.length < 6) {
      setPasswordError(true);
      setPasswordErrorMessage(
        "Password must be at least 6 characters long."
      );
      isValid = false;
    } else {
      setPasswordError(false);
      setPasswordErrorMessage("");
    }

    return isValid;
  };

  return (
    <Box
      sx={{
        height: "340px",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",

        position: "relative",
      }}
    >
      {/* overlay */}
      <Box
        sx={{
          position: "absolute",
          inset: 0,
          background: "rgba(168, 146, 101, 0.6)",
        }}
      />

      {/* card wrapper */}
      <Box sx={{ zIndex: 2,                  marginTop: "140px",

}}>
        <Card variant="outlined">
          {/* logo */}
          <Box sx={{ display: { xs: "flex", md: "none" } }}>
            <SitemarkIcon />
          </Box>

          {/* title */}
          <Typography
            component="h1"
            variant="h4"
            sx={{ textAlign: "center", fontWeight: 700 }}
          >
            Sign in
          </Typography>

          {/* form */}
          <Box
            component="form"
            onSubmit={handleSubmit}
            noValidate
            sx={{
              display: "flex",
              flexDirection: "column",
              gap: 2,

            }}
          >
            {/* email */}
            <FormControl>
              <FormLabel htmlFor="email">Email</FormLabel>
              <TextField
                error={emailError}
                helperText={emailErrorMessage}
                id="email"
                type="email"
                name="email"
                placeholder="your@email.com"
                autoComplete="email"
                required
                fullWidth
              />
            </FormControl>

            {/* password */}
            <FormControl>
              <FormLabel htmlFor="password">Password</FormLabel>

              <TextField
                error={passwordError}
                helperText={passwordErrorMessage}
                name="password"
                placeholder="••••••"
                type="password"
                id="password"
                autoComplete="current-password"
                required
                fullWidth
              />

              {/* forgot تحت الحقل */}
              <Link
                component="button"
                type="button"
                onClick={handleClickOpen}
                variant="body2"
                sx={{
                  mt: 1,
                  textAlign: "right",
                }}
              >
                Forgot your password?
              </Link>
            </FormControl>

            <FormControlLabel
              control={<Checkbox value="remember" color="primary" />}
              label="Remember me"
            />

            <ForgotPassword open={open} handleClose={handleClose} />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{
                py: 1.3,
                borderRadius: 3,
                fontWeight: 600,
              }}
            >
              Sign in
            </Button>

            <Typography sx={{ textAlign: "center" }}>
              Don&apos;t have an account?{" "}
              <Link href="#" variant="body2">
                Sign up
              </Link>
            </Typography>
          </Box>

          <Divider>or</Divider>

          {/* social */}
          <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
            <Button
              fullWidth
              variant="outlined"
              startIcon={<GoogleIcon />}
            >
              Sign in with Google
            </Button>

            <Button
              fullWidth
              variant="outlined"
              startIcon={<FacebookIcon />}
            >
              Sign in with Facebook
            </Button>
          </Box>
        </Card>
      </Box>
    </Box>
  );
}