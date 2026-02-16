import './index.scss';
import { useState } from 'react';
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

	const [activePage, setActivePage] = useState('');
	const { totalItemCount } = useWorkbench();

	const navHandler = (event: MouseEvent) => {
		let target = event.target as HTMLElement;
		setActivePage(target.className);
	}

	return (
		<nav className={'navbar ' + activePage}>
			<div className="navbar__links">
				{
					elements.map((element) => {
						return (
							<div key={element.link} onClick = {() => navHandler}><Link to={element.link}>{element.label}</Link></div>
						)
					})
				}
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