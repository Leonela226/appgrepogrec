import 'package:flutter/material.dart';

class CustomPaginatedTable extends StatelessWidget {
  final List<DataColumn> columns;
  final DataTableSource dataSource;
  final String headerText; // Encabezado como texto
  final int rowsPerPage;

  const CustomPaginatedTable({
    super.key,
    required this.columns,
    required this.dataSource,
    this.headerText = 'Datos',  // Usamos solo un texto simple como encabezado
    this.rowsPerPage = 2,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: Center(  // Centramos el texto del encabezado
        child: Text(
          headerText,
          style: TextStyle(
            fontFamily: 'TitilliumWeb',
            fontWeight: FontWeight.w600, // SemiBold
            fontSize: 14,
          ),
        ),
      ),
      rowsPerPage: rowsPerPage,
      onPageChanged: (int index) {},
      columns: columns.map((column) {
        return DataColumn(
          label: Center(  // Aquí envolvemos el texto en un Center para alinearlo
            child: Text(
              (column.label as Text).data ?? '',  // Aseguramos que label es un Text
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.normal, // Regular
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
      source: dataSource,
      showCheckboxColumn: false, // Si no deseas las casillas de selección
      headingRowHeight: 25, // Ajusta este valor para reducir el espacio

    );
  }
}
