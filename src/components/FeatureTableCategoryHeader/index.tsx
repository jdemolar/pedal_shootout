import './index.scss'
import { MouseEvent } from "react";

interface Props {
	label: string;
	clnm: string;
	numColumns: number;
	tableClasses: string;
	setTableClasses: Function;
}

const FeatureTableCategoryHeader = ({label, clnm, numColumns, tableClasses, setTableClasses}: Props) => {

	const updateVisibility = (event: MouseEvent) => {
		let el = event.target as HTMLElement;
		let featureTableClassList = (tableClasses === '') ? [] : tableClasses.split(' ');
		let currentSection = el.parentElement?.className.replace('category-header-cell ', '');
		let hideClassName = 'hide-' + currentSection;
		let i = featureTableClassList?.indexOf(hideClassName);
		
		if (i === -1) {
			featureTableClassList.push(hideClassName);
		} else {
			featureTableClassList.splice(i, 1);
		}

		setTableClasses(featureTableClassList.join(' '));
	}

	return (
		<th className={'category-header-cell ' + clnm} data-label={label} colSpan={numColumns}>
			<span className='collapse-button' onClick={updateVisibility}>X</span>
			<span className="label" onClick={updateVisibility}>{label}</span>
			{label}
		</th>
	)
}

export default FeatureTableCategoryHeader;