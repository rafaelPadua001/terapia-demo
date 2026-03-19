from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from starlette.concurrency import run_in_threadpool

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models import Evaluation
from app.schemas.schemas import (
    EvaluationCreate,
    EvaluationOut,
    EvaluationUpdate,
    EvaluationValidateRequest,
    EvaluationsPage,
    ValidationOut,
)
from app.services.evaluation_service import (
    create_evaluation,
    generate_evaluation_pdf,
    list_evaluations,
    soft_delete_evaluation,
    update_evaluation,
    validate_evaluation,
)

router = APIRouter(prefix="/evaluations", tags=["evaluations"])


@router.post("", response_model=EvaluationOut, dependencies=[Depends(require_role("admin", "therapist"))])
def create(data: EvaluationCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    return create_evaluation(db, clinic_id=user.clinic_id, user_id=user.id, evaluation_in=data)


@router.get(
    "",
    response_model=EvaluationsPage,
    dependencies=[Depends(require_role("admin", "therapist", "receptionist", "patient", "guardian"))],
)
def list_all(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = None,
    status: str | None = None,
    patient_id: str | None = None,
    show_deleted: bool = False,
):
    items, total = list_evaluations(
        db,
        user,
        page,
        limit,
        search=search,
        status=status,
        patient_id=patient_id,
        show_deleted=show_deleted,
    )
    return EvaluationsPage(items=items, total=total, page=page, limit=limit)


@router.put("/{evaluation_id}", response_model=EvaluationOut, dependencies=[Depends(require_role("admin", "therapist"))])
def update(evaluation_id: str, data: EvaluationUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        return update_evaluation(db, clinic_id=user.clinic_id, evaluation_id=evaluation_id, evaluation_in=data, updated_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.delete("/{evaluation_id}", status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(require_role("admin", "therapist"))])
def delete(evaluation_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        soft_delete_evaluation(db, clinic_id=user.clinic_id, evaluation_id=evaluation_id, deleted_by=user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.post("/{evaluation_id}/validate", response_model=ValidationOut, dependencies=[Depends(require_role("admin", "therapist"))])
def validate(
    evaluation_id: str,
    payload: EvaluationValidateRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if payload.status not in {"pending", "approved", "rejected"}:
        raise HTTPException(status_code=400, detail="Invalid status")
    try:
        return validate_evaluation(
            db,
            clinic_id=user.clinic_id,
            user_id=user.id,
            evaluation_id=evaluation_id,
            status=payload.status,
            notes=payload.notes,
        )
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))


@router.get("/{evaluation_id}/pdf", dependencies=[Depends(require_role("admin", "therapist"))])
async def pdf(evaluation_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    try:
        pdf_bytes = await run_in_threadpool(generate_evaluation_pdf, db, user.clinic_id, evaluation_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc))

    return StreamingResponse(
        iter([pdf_bytes]),
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=evaluation_{evaluation_id}.pdf"},
    )
