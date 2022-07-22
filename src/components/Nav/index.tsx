import './index.scss';
import { useState } from 'react';

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
						<div onClick = {() => navHandler}>{element.label}</div>
					)
				})
			}
		</nav>
	);
}

export default Nav;