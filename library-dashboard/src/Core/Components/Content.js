import Box from "@mui/material/Box";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import AutoFixHighRoundedIcon from "@mui/icons-material/AutoFixHighRounded";
import ConstructionRoundedIcon from "@mui/icons-material/ConstructionRounded";
import SettingsSuggestRoundedIcon from "@mui/icons-material/SettingsSuggestRounded";
import ThumbUpAltRoundedIcon from "@mui/icons-material/ThumbUpAltRounded";

const items = [
  {
    icon: <SettingsSuggestRoundedIcon />,
    title: "Adaptable performance",
    description:
      "Our product effortlessly adjusts to your needs, boosting efficiency.",
  },
  {
    icon: <ConstructionRoundedIcon />,
    title: "Built to last",
    description:
      "Experience unmatched durability with long-term reliability.",
  },
  {
    icon: <ThumbUpAltRoundedIcon />,
    title: "Great user experience",
    description:
      "Simple, intuitive interface that fits into your workflow.",
  },
  {
    icon: <AutoFixHighRoundedIcon />,
    title: "Innovative functionality",
    description:
      "Modern features designed for your evolving needs.",
  },
];

export default function Content() {
  return (
    <Stack
      sx={{
        flexDirection: "column",
        gap: 4,
        maxWidth: 480,
        color: "#fff",
        
      }}
    >
      {/*  Title */}
      <Box>

        <Typography
          sx={{
            mt: 2,
            fontSize: 28,
            fontWeight: 700,
          }}
        >
          Smart Library System
        </Typography>

        <Typography sx={{ opacity: 0.7, mt: 1 }}>
          Manage your library efficiently with a modern digital system.
        </Typography>
      </Box>

      {/* Features */}
      <Stack spacing={2}>
        {items.map((item, index) => (
          <Box
            key={index}
            sx={{
              display: "flex",
              gap: 2,
              p: 2,
              borderRadius: 3,
              background: "rgba(255,255,255,0.08)",
              backdropFilter: "blur(10px)",
              border: "1px solid rgba(255,255,255,0.1)",
              transition: "0.3s",
              cursor: "pointer",

              "&:hover": {
                transform: "translateY(-4px)",
                background: "rgba(255,255,255,0.15)",
              },
            }}
          >
            {/* icon */}
            <Box
              sx={{
                width: 42,
                height: 42,
                borderRadius: "50%",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                background: "rgba(255,255,255,0.15)",
                color: "#fff",
              }}
            >
              {item.icon}
            </Box>

            {/* text */}
            <Box>
              <Typography sx={{ fontWeight: 600 }}>
                {item.title}
              </Typography>
              <Typography sx={{ opacity: 0.7, fontSize: 14 }}>
                {item.description}
              </Typography>
            </Box>
          </Box>
        ))}
      </Stack>
    </Stack>
  );
}