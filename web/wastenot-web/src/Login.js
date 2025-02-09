import { useNavigate } from "react-router-dom";

const Login = () => {
    const navigate = useNavigate();
    const handleLogin = () => {
        navigate("/home");
    }

    return ( 
        <div className="login">
            <h2>Login</h2>
            <input type="text" placeholder="Username" />
            <input type="password" placeholder="Password" />
            <button onClick={handleLogin}>Login</button>
        </div>
     );
}
 
export default Login;