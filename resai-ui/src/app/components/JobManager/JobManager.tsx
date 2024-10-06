import * as React from "react";
import {
  Grid,
  GridColumn as Column,
  GridSelectionChangeEvent,
  GridKeyDownEvent,
  getSelectedState,
  getSelectedStateFromKeyDown,
} from "@progress/kendo-react-grid";

import products from "./shared-gd-products.json";

import { getter } from "@progress/kendo-react-common";

import { Product } from "./shared-gd-interfaces";

const DATA_ITEM_KEY = "ProductID";
const SELECTED_FIELD = "selected";
const idGetter = getter(DATA_ITEM_KEY);

const App = () => {
  const [data, setData] = React.useState<Product[]>(
    products.map((dataItem: Product) =>
      Object.assign({ selected: false }, dataItem)
    )
  );
  const [selectedState, setSelectedState] = React.useState<{
    [id: string]: boolean | number[];
  }>({});

  const onSelectionChange = (event: GridSelectionChangeEvent) => {
    const newSelectedState = getSelectedState({
      event,
      selectedState: selectedState,
      dataItemKey: DATA_ITEM_KEY,
    });
    setSelectedState(newSelectedState);
  };

  const onKeyDown = (event: GridKeyDownEvent) => {
    const newSelectedState = getSelectedStateFromKeyDown({
      event,
      selectedState: selectedState,
      dataItemKey: DATA_ITEM_KEY,
    });
    setSelectedState(newSelectedState);
  };

  return (
    <div>
      <div style={{ padding: "5px", color: "#999" }}>
        <div>Ctrl+Click/Enter - add to selection</div>
        <div>Shift+Click/Enter - select range </div>
      </div>
      <Grid
        style={{ height: "400px" }}
        data={data.map((item) => ({
          ...item,
          [SELECTED_FIELD]: selectedState[idGetter(item)],
        }))}
        dataItemKey={DATA_ITEM_KEY}
        selectedField={SELECTED_FIELD}
        selectable={{
          enabled: true,
          drag: true,
          mode: "multiple",
        }}
        navigatable={true}
        onSelectionChange={onSelectionChange}
        onKeyDown={onKeyDown}
      >
        <Column field="ProductName" title="Product Name" width="300px" />
        <Column field="UnitsInStock" title="Units In Stock" />
        <Column field="UnitsOnOrder" title="Units On Order" />
        <Column field="ReorderLevel" title="Reorder Level" />
      </Grid>
    </div>
  );
};

export default App;
