package com.seassignment.backend.task3;

import java.util.ArrayList;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Types;

import org.springframework.jdbc.core.CallableStatementCallback;
import org.springframework.jdbc.core.CallableStatementCreator;

@Repository
public class InvoiceRepository {

    private final JdbcTemplate jdbcTemplate;

    public InvoiceRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<InvoiceResult> findInvoices(Long invoiceId, String status) {

        StringBuilder sql = new StringBuilder("""
                SELECT
                    invoice_id,
                    invoice_date,
                    invoice_amount,
                    currency,
                    status,
                    debt_amount
                FROM TABLE(get_invoice_statuses(?))
                """);

        List<Object> params = new ArrayList<>();
        params.add(invoiceId);

        if (status != null && !status.isBlank()) {
            sql.append(" WHERE status = ?");
            params.add(status.toUpperCase());
        }

        sql.append(" ORDER BY invoice_id");

        return jdbcTemplate.query(
                sql.toString(),
                (rs, rowNum) -> new InvoiceResult(
                        rs.getLong("invoice_id"),
                        rs.getDate("invoice_date").toLocalDate(),
                        rs.getBigDecimal("invoice_amount"),
                        rs.getString("currency"),
                        rs.getString("status"),
                        rs.getBigDecimal("debt_amount")
                ),
                params.toArray()
        );
    }

    public List<PaymentResult> findPayments(Long invoiceId) {

        StringBuilder sql = new StringBuilder("""
                SELECT
                    p.payment_id,
                    p.invoice_id,
                    p.payment_date,
                    p.payment_amount
                FROM payment p
                """);

        List<Object> params = new ArrayList<>();

        if (invoiceId != null) {
            sql.append(" WHERE p.invoice_id = ?");
            params.add(invoiceId);
        }

        sql.append(" ORDER BY p.payment_id");

        return jdbcTemplate.query(
                sql.toString(),
                (rs, rowNum) -> new PaymentResult(
                        rs.getLong("payment_id"),
                        rs.getLong("invoice_id"),
                        rs.getDate("payment_date").toLocalDate(),
                        rs.getBigDecimal("payment_amount")
                ),
                params.toArray()
        );
    }

    public PaymentOperationResult addPayment(PaymentRequest request) {

        String sql = """
                DECLARE
                    l_result payment_operation_result_t;
                BEGIN
                    l_result := add_payment(?, ?, ?);

                    ? := l_result.status_code;
                    ? := l_result.error_code;
                    ? := l_result.message;
                END;
                """;

        CallableStatementCreator statementCreator = connection -> {
            CallableStatement statement = connection.prepareCall(sql);

            statement.setObject(1, request.invoiceId());
            statement.setDate(2, java.sql.Date.valueOf(request.paymentDate()));
            statement.setBigDecimal(3, request.paymentAmount());

            statement.registerOutParameter(4, Types.VARCHAR);
            statement.registerOutParameter(5, Types.NUMERIC);
            statement.registerOutParameter(6, Types.VARCHAR);

            return statement;
        };

        CallableStatementCallback<PaymentOperationResult> callback = statement -> {
            statement.execute();

            String statusCode = statement.getString(4);
            BigDecimal errorCodeValue = statement.getBigDecimal(5);
            Integer errorCode = errorCodeValue == null ? null : errorCodeValue.intValue();
            String message = statement.getString(6);

            return new PaymentOperationResult(
                    statusCode,
                    errorCode,
                    message
            );
        };

        return jdbcTemplate.execute(statementCreator, callback);
    }
}