import './index.scss';
import { Link } from 'react-router-dom';
import { useWorkbench } from '../../context/WorkbenchContext';

interface element {
	label: string;
	link: string;
};

interface Props {
	elements: element[];
}

const Nav = ({elements}: Props) => {

	const { totalItemCount } = useWorkbench();

	return (
		<nav className="navbar">
			<div className="navbar__links">
				{elements.map((element) => (
					<Link key={element.link} to={element.link}>{element.label}</Link>
				))}
			</div>
			<div className="navbar__workbench">
				<Link to="/workbench" className="navbar__workbench-link">
					<span className="navbar__workbench-icon">{'\u2692'}</span>
					<span className="navbar__workbench-label">Workbench</span>
					{totalItemCount > 0 && (
						<span className="navbar__workbench-badge">{totalItemCount}</span>
					)}
				</Link>
			</div>
		</nav>
	);
}

export default Nav;
