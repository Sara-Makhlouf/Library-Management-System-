
import MenuBookOutlinedIcon   from "@mui/icons-material/MenuBookOutlined";
import LayersOutlinedIcon     from "@mui/icons-material/LayersOutlined";
import CheckCircleOutlineIcon from "@mui/icons-material/CheckCircleOutline";
import {
  Box,

} from "@mui/material";
import {GOLD} from "../../Core/Constants/utils";

export const KPI = [
  { label: "Total Books", icon: <MenuBookOutlinedIcon  sx={{ fontSize: 16 }} />, accent: GOLD,      trend: "all time" },
  { label: "This Page",   icon: <CheckCircleOutlineIcon sx={{ fontSize: 16 }} />, accent: "#97c459", trend: "current view" },
  { label: "Total Pages", icon: <LayersOutlinedIcon    sx={{ fontSize: 16 }} />, accent: "#7f77dd", trend: "paginated" },
];

export function StockBar({ stock, max, accent }) {
  const pct = max > 0 ? Math.round((stock / max) * 100) : 0;
  return (
    <Box sx={{ height: 3, borderRadius: 2, bgcolor: "rgba(255,255,255,0.07)", overflow: "hidden", mt: 1.5 }}>
      <Box sx={{ height: "100%", width: `${pct}%`, bgcolor: accent, borderRadius: 2, transition: "width 0.4s ease" }} />
    </Box>
  );
}
