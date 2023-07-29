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
        (know__non-covid-illness)
        (non-covid-illness)
        (completed-diagnostic)
        (goal)
        (have-message)
        (force-statement)
        (symptoms-value-covid)
        (symptoms-value-rash)
        (symptoms-value-teeth)
    )
    (:action get_symptoms
        :parameters()
        :precondition
            (and
                (have-symptoms)
                (not (force-statement))
            )
        :effect
            (labeled-oneof get_symptoms__get-symptoms
                (outcome share-covid
                    (and
                        (know__symptoms)
                        (not (symptoms-value-rash))
                        (symptoms-value-covid)
                        (not (symptoms-value-teeth))
                    )
                )
                (outcome share-rash
                    (and
                        (know__symptoms)
                        (symptoms-value-rash)
                        (not (symptoms-value-teeth))
                        (not (symptoms-value-covid))
                    )
                )
                (outcome share-teeth
                    (and
                        (know__symptoms)
                        (not (symptoms-value-rash))
                        (symptoms-value-teeth)
                        (not (symptoms-value-covid))
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
    (:action handle_no_issues
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (covid-exposure))
                (not (completed-diagnostic))
                (not (have-symptoms))
                (know__have-symptoms)
                (know__covid-exposure)
            )
        :effect
            (labeled-oneof handle_no_issues__check-test
                (outcome no-exposure-no-symptoms
                    (and
                        (completed-diagnostic)
                    )
                )
            )
    )
    (:action need-covid-diagnostic-1
        :parameters()
        :precondition
            (and
                (know__symptoms)
                (not (know__non-covid-illness))
                (not (force-statement))
                (symptoms-value-covid)
            )
        :effect
            (labeled-oneof need-covid-diagnostic-1__check-test
                (outcome covid-symptoms
                    (and
                        (not (non-covid-illness))
                        (know__non-covid-illness)
                    )
                )
            )
    )
    (:action need-covid-diagnostic-2
        :parameters()
        :precondition
            (and
                (not (know__non-covid-illness))
                (not (force-statement))
                (covid-exposure)
            )
        :effect
            (labeled-oneof need-covid-diagnostic-2__check-test
                (outcome covid-symptoms
                    (and
                        (not (non-covid-illness))
                        (know__non-covid-illness)
                    )
                )
            )
    )
    (:action determine-is-non-covid-illness
        :parameters()
        :precondition
            (and
                (know__symptoms)
                (not (know__non-covid-illness))
                (not (force-statement))
                (know__covid-exposure)
            )
        :effect
            (labeled-oneof determine-is-non-covid-illness__check-test
                (outcome rash
                    (and
                        (non-covid-illness)
                        (know__non-covid-illness)
                    )
                )
                (outcome teeth
                    (and
                        (non-covid-illness)
                        (know__non-covid-illness)
                    )
                )
            )
    )
    (:action diagnose_regular_sickness
        :parameters()
        :precondition
            (and
                (non-covid-illness)
                (not (force-statement))
                (know__over-week)
                (not (completed-diagnostic))
                (know__non-covid-illness)
            )
        :effect
            (labeled-oneof diagnose_regular_sickness__check-test
                (outcome rash-under
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome rash-over
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome teeth
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
            )
    )
    (:action determine_covid_test
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__symptoms)
                (know__exposure-period-over-5)
                (not (completed-diagnostic))
                (know__positive-90)
                (know__positive-30)
                (know__non-covid-illness)
                (not (non-covid-illness))
                (know__covid-exposure)
            )
        :effect
            (labeled-oneof determine_covid_test__check-test
                (outcome no-symptom-exposed-been-5
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome no-symptom-exposed-less-5
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome have-symptoms-no-90
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome have-symptoms-30
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome have-no-symptoms-30
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome have-symptoms-90
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
                (outcome have-no-symptoms-90
                    (and
                        (have-message)
                        (force-statement)
                        (completed-diagnostic)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (completed-diagnostic)
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
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__get_have_symptoms
        :parameters()
        :precondition
            (and
                (not (know__have-symptoms))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get_have_symptoms__get-response
                (outcome confirm_outcome
                    (and
                        (force-statement)
                        (have-symptoms)
                        (know__have-symptoms)
                        (have-message)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (symptoms-value-teeth))
                        (know__symptoms)
                        (not (symptoms-value-covid))
                        (not (have-symptoms))
                        (not (symptoms-value-rash))
                        (know__have-symptoms)
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
                (have-symptoms)
                (not (force-statement))
                (not (know__over-week))
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
                        (not (over-week))
                        (know__over-week)
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
                (not (force-statement))
                (not (know__covid-exposure))
            )
        :effect
            (labeled-oneof slot-fill__get_covid_exposure__get-response
                (outcome confirm_outcome
                    (and
                        (covid-exposure)
                        (know__covid-exposure)
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
                (not (force-statement))
                (not (know__exposure-period-over-5))
                (know__non-covid-illness)
                (not (non-covid-illness))
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
                (not (force-statement))
                (not (know__positive-30))
                (not (non-covid-illness))
                (know__non-covid-illness)
            )
        :effect
            (labeled-oneof slot-fill__get_positive_30__get-response
                (outcome confirm_outcome
                    (and
                        (positive-30)
                        (know__positive-30)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (positive-30))
                        (know__positive-30)
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
                (not (force-statement))
                (not (know__positive-90))
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
