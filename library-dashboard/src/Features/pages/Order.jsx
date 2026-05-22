import {
  Box,
  Typography,
  Card,
  CardContent,
  Avatar,
  Chip,
  LinearProgress,
  Button,
} from "@mui/material";

export default function Orders() {
  const employees = [
    {
      name: "Ahmed Ali",
      role: "Delivery Driver",
      status: "Active",
      orders: 12,
      progress: 70,
    },
    {
      name: "Sara Mohamed",
      role: "Delivery Driver",
      status: "Busy",
      orders: 8,
      progress: 40,
    },
  ];

  const emptySlots = 2;

  return (
    <Box
      sx={{
        p: 4,
        minHeight: "100vh",
        background:
          "linear-gradient(135deg, #f8f6ef 0%, #f1eee6 100%)",
      }}
    >
      {/* HEADER */}
      <Box
        sx={{
          mb: 4,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Box>
          <Typography sx={{ fontSize: "2rem", fontWeight: 700 }}>
            Delivery Control
          </Typography>
          <Typography sx={{ opacity: 0.6 }}>
            Manage drivers & assignments in real-time
          </Typography>
        </Box>

        <Button
          variant="contained"
          sx={{
            borderRadius: "12px",
            background: "rgb(189,170,127)",
            "&:hover": {
              background: "rgb(160,140,100)",
            },
          }}
        >
          + Add Driver
        </Button>
      </Box>

      {/* GRID */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: 3,
        }}
      >
        {/* EMPLOYEES */}
        {employees.map((emp, index) => (
          <Card
            key={index}
            sx={{
              borderRadius: "22px",
              p: 1,
              backdropFilter: "blur(10px)",
              background: "rgba(255,255,255,0.7)",
              boxShadow: "0 15px 35px rgba(0,0,0,0.08)",
              transition: "0.35s",

              "&:hover": {
                transform: "translateY(-8px)",
                boxShadow: "0 25px 45px rgba(0,0,0,0.12)",
              },
            }}
          >
            <CardContent>
              {/* TOP */}
              <Box
                sx={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                }}
              >
                <Box sx={{ display: "flex", gap: 2 }}>
                  <Avatar
                    sx={{
                      bgcolor: "rgb(189,170,127)",
                      width: 50,
                      height: 50,
                      fontSize: "1.3rem",
                    }}
                  >
                    {emp.name.charAt(0)}
                  </Avatar>

                  <Box>
                    <Typography sx={{ fontWeight: 600 }}>
                      {emp.name}
                    </Typography>
                    <Typography sx={{ fontSize: "0.75rem", opacity: 0.6 }}>
                      {emp.role}
                    </Typography>
                  </Box>
                </Box>

                <Chip
                  label={emp.status}
                  size="small"
                  sx={{
                    bgcolor:
                      emp.status === "Active"
                        ? "#e8f5e9"
                        : "#fff3e0",
                  }}
                />
              </Box>

              {/* PROGRESS */}
              <Box sx={{ mt: 3 }}>
                <Typography
                  sx={{
                    fontSize: "0.75rem",
                    mb: 0.5,
                    opacity: 0.6,
                  }}
                >
                  Workload
                </Typography>

                <LinearProgress
                  variant="determinate"
                  value={emp.progress}
                  sx={{
                    height: 8,
                    borderRadius: 5,
                    background: "#eee",
                    "& .MuiLinearProgress-bar": {
                      background:
                        "linear-gradient(90deg, #c2a96b, #a78b4d)",
                    },
                  }}
                />
              </Box>

              {/* BOTTOM */}
              <Box
                sx={{
                  mt: 2,
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                }}
              >
                <Typography sx={{ fontSize: "0.85rem" }}>
                  {emp.orders} Orders
                </Typography>

                <Button size="small" sx={{ fontSize: "0.75rem" }}>
                  View
                </Button>
              </Box>
            </CardContent>
          </Card>
        ))}

        {/* EMPTY SLOTS */}
        {Array.from({ length: emptySlots }).map((_, i) => (
          <Card
            key={i}
            sx={{
              borderRadius: "22px",
              border: "2px dashed rgba(0,0,0,0.15)",
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              minHeight: 200,
              background: "rgba(255,255,255,0.4)",
              backdropFilter: "blur(8px)",
              cursor: "pointer",
              transition: "0.3s",

              "&:hover": {
                background: "white",
                transform: "scale(1.04)",
              },
            }}
          >
            <Typography sx={{ fontSize: "2.5rem", opacity: 0.4 }}>
              +
            </Typography>

            <Typography sx={{ opacity: 0.6 }}>
              Assign Driver
            </Typography>
          </Card>
        ))}
      </Box>
    </Box>
  );
}