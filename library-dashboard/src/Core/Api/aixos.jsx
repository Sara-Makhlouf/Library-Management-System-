import axios from "axios";

const axiosClient = axios.create({
  baseURL: "http://127.0.0.1:8000/api/admin",
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json",
  },
});

export const getAuthConfig = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem("admin_token")}`,
    Accept: "application/json",
  },
});

export default axiosClient;
