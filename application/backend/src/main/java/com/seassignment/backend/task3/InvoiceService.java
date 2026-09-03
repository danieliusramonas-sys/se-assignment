package com.seassignment.backend.task3;

import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;

    public InvoiceService(InvoiceRepository invoiceRepository) {
        this.invoiceRepository = invoiceRepository;
    }

    public List<InvoiceResult> findInvoices(
            Long invoiceId,
            String status
    ) {
        return invoiceRepository.findInvoices(invoiceId, status);
    }

    public List<PaymentResult> findPayments(Long invoiceId) {
        return invoiceRepository.findPayments(invoiceId);
    }

    public PaymentOperationResult addPayment(
            PaymentRequest request
    ) {
        return invoiceRepository.addPayment(request);
    }
}