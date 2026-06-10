import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const loginAdmin = createApiThunk(
  "auth/loginAdmin",
  async (loginData) => {
    const response = await api.post("/login", {
      email: loginData.email,
      password: loginData.password,
    });
    return response.data;
  }
);

export default loginAdmin;
