(define
    (domain medical_bot)
    (:requirements :strips)
    (:types )
    (:constants )
    (:predicates
        (know__have-symptoms)
        (have-symptoms)
        (know__symptoms)
        (know__over-week)
        (over-week)
        (know__covid-exposure)
        (covid-exposure)
        (know__exposure-period-over-5)
        (exposure-period-over-5)
        (know__positive-30)
        (positive-30)
        (know__positive-90)
        (positive-90)
        (know__need-reg-diag)
        (need-reg-diag)
        (know__need-covid-diag)
        (need-covid-diag)
        (ran-reg-diag)
        (ran-covid-diag)
        (no-covid-symptoms)
        (completed-diagnostics)
        (goal)
        (have-message)
        (force-statement)
        (forcing__diagnose_regular_sickness)
    )
    (:action get_symptoms
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (force-statement))
                (not (know__symptoms))
                (have-symptoms)
            )
        :effect
            (labeled-oneof get_symptoms__get-symptoms
                (outcome share-covid
                    (and
                        (not (no-covid-symptoms))
                        (know__symptoms)
                    )
                )
                (outcome share-rash
                    (and
                        (know__symptoms)
                        (no-covid-symptoms)
                    )
                )
                (outcome share-teeth
                    (and
                        (know__symptoms)
                        (no-covid-symptoms)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action progress_no_symptoms_cases
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (know__have-symptoms)
                (not (have-symptoms))
                (not (force-statement))
                (know__covid-exposure)
                (not (completed-diagnostics))
                (not (know__need-covid-diag))
            )
        :effect
            (labeled-oneof progress_no_symptoms_cases__check-test
                (outcome no-exposure-no-symptoms
                    (and
                        (force-statement)
                        (have-message)
                        (completed-diagnostics)
                    )
                )
                (outcome proceed
                    (and
                        (force-statement)
                        (not (need-reg-diag))
                        (have-message)
                        (need-covid-diag)
                        (know__need-reg-diag)
                        (know__need-covid-diag)
                        (no-covid-symptoms)
                    )
                )
            )
    )
    (:action progress_symptoms_cases
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (know__need-reg-diag))
                (not (force-statement))
                (know__covid-exposure)
                (know__symptoms)
                (have-symptoms)
                (not (know__need-covid-diag))
            )
        :effect
            (labeled-oneof progress_symptoms_cases__check-test
                (outcome covid
                    (and
                        (need-covid-diag)
                        (know__need-reg-diag)
                        (know__need-covid-diag)
                        (not (need-reg-diag))
                    )
                )
                (outcome rash-covid
                    (and
                        (forcing__diagnose_regular_sickness)
                        (need-covid-diag)
                        (know__need-reg-diag)
                        (need-reg-diag)
                        (know__need-covid-diag)
                    )
                )
                (outcome teeth-covid
                    (and
                        (forcing__diagnose_regular_sickness)
                        (need-covid-diag)
                        (know__need-reg-diag)
                        (need-reg-diag)
                        (know__need-covid-diag)
                    )
                )
                (outcome rash-no-covid
                    (and
                        (know__need-reg-diag)
                        (need-reg-diag)
                        (know__need-covid-diag)
                        (not (need-covid-diag))
                    )
                )
                (outcome teeth-no-covid
                    (and
                        (know__need-reg-diag)
                        (need-reg-diag)
                        (know__need-covid-diag)
                        (not (need-covid-diag))
                    )
                )
            )
    )
    (:action diagnose_regular_sickness
        :parameters()
        :precondition
            (and
                (not (ran-reg-diag))
                (need-reg-diag)
                (not (force-statement))
                (know__over-week)
            )
        :effect
            (labeled-oneof diagnose_regular_sickness__check-test
                (outcome rash-under
                    (and
                        (ran-reg-diag)
                        (force-statement)
                        (have-message)
                        (not (forcing__diagnose_regular_sickness))
                    )
                )
                (outcome rash-over
                    (and
                        (ran-reg-diag)
                        (force-statement)
                        (have-message)
                        (not (forcing__diagnose_regular_sickness))
                    )
                )
                (outcome teeth
                    (and
                        (ran-reg-diag)
                        (force-statement)
                        (have-message)
                        (not (forcing__diagnose_regular_sickness))
                    )
                )
            )
    )
    (:action determine_covid_test
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (know__exposure-period-over-5)
                (not (force-statement))
                (know__positive-90)
                (not (ran-covid-diag))
                (need-covid-diag)
                (know__covid-exposure)
                (know__symptoms)
                (know__positive-30)
            )
        :effect
            (labeled-oneof determine_covid_test__check-test
                (outcome have-no-symptoms-30
                    (and
                        (ran-covid-diag)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome have-symptoms-30
                    (and
                        (ran-covid-diag)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome have-symptoms-no-90
                    (and
                        (ran-covid-diag)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome have-symptoms-90
                    (and
                        (ran-covid-diag)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome have-no-symptoms-90
                    (and
                        (ran-covid-diag)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome no-symptom-exposed-been-5
                    (and
                        (ran-covid-diag)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome no-symptom-exposed-less-5
                    (and
                        (ran-covid-diag)
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action got-both-diags
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (ran-reg-diag)
                (not (force-statement))
                (need-covid-diag)
                (know__need-reg-diag)
                (need-reg-diag)
                (know__need-covid-diag)
                (not (completed-diagnostics))
                (ran-covid-diag)
            )
        :effect
            (labeled-oneof got-both-diags__check-test
                (outcome complete
                    (and
                        (completed-diagnostics)
                    )
                )
            )
    )
    (:action got-covid-diag
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (need-reg-diag))
                (not (force-statement))
                (need-covid-diag)
                (know__need-reg-diag)
                (know__need-covid-diag)
                (not (completed-diagnostics))
                (ran-covid-diag)
            )
        :effect
            (labeled-oneof got-covid-diag__check-test
                (outcome complete
                    (and
                        (completed-diagnostics)
                    )
                )
            )
    )
    (:action got-reg-diag
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (ran-reg-diag)
                (not (force-statement))
                (know__need-reg-diag)
                (need-reg-diag)
                (know__need-covid-diag)
                (not (completed-diagnostics))
                (not (need-covid-diag))
            )
        :effect
            (labeled-oneof got-reg-diag__check-test
                (outcome complete
                    (and
                        (completed-diagnostics)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (force-statement))
                (completed-diagnostics)
            )
        :effect
            (labeled-oneof complete__finish
                (outcome finish
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (force-statement)
                (have-message)
            )
        :effect
            (labeled-oneof dialogue_statement__reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__get_have_symptoms
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (know__have-symptoms))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get_have_symptoms__get-response
                (outcome confirm_outcome
                    (and
                        (know__have-symptoms)
                        (force-statement)
                        (have-message)
                        (have-symptoms)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__have-symptoms)
                        (know__symptoms)
                        (not (have-symptoms))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get_sickness_period
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (force-statement))
                (not (know__over-week))
                (have-symptoms)
            )
        :effect
            (labeled-oneof slot-fill__get_sickness_period__get-response
                (outcome confirm_outcome
                    (and
                        (over-week)
                        (know__over-week)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__over-week)
                        (not (over-week))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get_covid_exposure
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (know__covid-exposure))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get_covid_exposure__get-response
                (outcome confirm_outcome
                    (and
                        (know__covid-exposure)
                        (covid-exposure)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (covid-exposure))
                        (know__covid-exposure)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get_exposure_period
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (know__exposure-period-over-5))
                (not (force-statement))
                (need-covid-diag)
                (know__covid-exposure)
            )
        :effect
            (labeled-oneof slot-fill__get_exposure_period__get-response
                (outcome confirm_outcome
                    (and
                        (know__exposure-period-over-5)
                        (exposure-period-over-5)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__exposure-period-over-5)
                        (not (exposure-period-over-5))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get_positive_30
        :parameters()
        :precondition
            (and
                (need-covid-diag)
                (not (forcing__diagnose_regular_sickness))
                (not (know__positive-30))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get_positive_30__get-response
                (outcome confirm_outcome
                    (and
                        (know__positive-30)
                        (positive-90)
                        (positive-30)
                        (know__positive-90)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__positive-30)
                        (not (positive-30))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get_positive_90
        :parameters()
        :precondition
            (and
                (not (forcing__diagnose_regular_sickness))
                (not (know__positive-90))
                (not (positive-30))
                (not (force-statement))
                (know__positive-30)
            )
        :effect
            (labeled-oneof slot-fill__get_positive_90__get-response
                (outcome confirm_outcome
                    (and
                        (positive-90)
                        (know__positive-90)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (positive-90))
                        (know__positive-90)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
)
