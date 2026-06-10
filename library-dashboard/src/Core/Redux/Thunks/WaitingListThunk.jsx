import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getBooksInvaliable = createApiThunk(
  "waitingList/getBooksInvaliable",
  async () => {
    const response = await api.get("/admin/waiting-list");
    return response.data;
  }
);

export default getBooksInvaliable;
