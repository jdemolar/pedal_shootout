import { Spinner } from "react-bootstrap";
import  './index.scss';

function Loading () {
	return (
		<Spinner animation="border" variant="primary" className="spinner">
			<span className="sr-only app-logo">Loading...</span>
		</Spinner>
	)
}

export default Loading;