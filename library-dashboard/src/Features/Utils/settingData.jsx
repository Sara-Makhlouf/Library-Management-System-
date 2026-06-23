import { motion } from "framer-motion";
import {
  Box,
 
} from "@mui/material";
export const BG      = "#0a0a0f";
export const SURFACE = "#111118";
export const GOLD    = "#c9a84c";
export const GOLD2   = "#8b5e1a";
export const BORDER  = "rgba(255,255,255,0.06)";
export const BORDER2 = "rgba(255,255,255,0.10)";
export const TEXT    = "#fff";
export const MUTED   = "rgba(255,255,255,0.35)";

export const fieldSx = {
  "& .MuiOutlinedInput-root": {
    borderRadius: "10px", fontSize: 13.5, color: TEXT,
    bgcolor: "rgba(255,255,255,0.04)",
    "& fieldset":             { borderColor: BORDER },
    "&:hover fieldset":       { borderColor: BORDER2 },
    "&.Mui-focused fieldset": { borderColor: `${GOLD}60` },
  },
  "& .MuiInputLabel-root":             { fontSize: 13.5, color: MUTED },
  "& .MuiInputLabel-root.Mui-focused": { color: GOLD },
  "& input": { color: TEXT },
};

export function SectionCard({ children, sx = {} }) {
  return (
    <Box
      component={motion.div}
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      sx={{
        p: "20px", borderRadius: "18px",
        bgcolor: SURFACE, border: `1px solid ${BORDER}`,
        transition: "all 0.25s",
        ...sx,
      }}
    >
      {children}
    </Box>
  );
}
