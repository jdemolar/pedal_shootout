import './index.scss';
import { useState } from 'react';
import { Link } from 'react-router-dom';

interface element {
	label: string;
	link: string;
};

interface Props {
	elements: element[];
}

const Nav = ({elements}: Props) => {
	
	const [activePage, setActivePage] = useState('');

	const navHandler = (event: MouseEvent) => {
		let target = event.target as HTMLElement;
		setActivePage(target.className);
	}

	return (
		<nav className={'navbar ' + activePage}>
			{
				elements.map((element) => {
					return (
						<div key={element.link} onClick = {() => navHandler}><Link to={element.link}>{element.label}</Link></div>
					)
				})
			}
		</nav>
	);
}

export default Nav;